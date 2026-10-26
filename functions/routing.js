const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

const SERVICE_TYPES = ["medical", "police", "fire"];

const toRad = (d) => (d * Math.PI) / 180;

// Haversine distance in meters between two GeoPoints.
function distanceMeters(a, b) {
  const R = 6371000;
  const dLat = toRad(b.latitude - a.latitude);
  const dLng = toRad(b.longitude - a.longitude);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(a.latitude)) * Math.cos(toRad(b.latitude)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

// Nearest active station of one service type, or null if there is none.
async function nearestStation(type, location) {
  const snap = await admin.firestore()
      .collection("emergencyServices")
      .where("type", "==", type)
      .where("isActive", "==", true)
      .get();

  let best = null;
  let bestDist = Infinity;
  snap.forEach((doc) => {
    const loc = doc.get("location");
    if (!loc) return;
    const d = distanceMeters(location, loc);
    if (d < bestDist) {
      best = doc;
      bestDist = d;
    }
  });
  return best ? {id: best.id, distance: Math.round(bestDist)} : null;
}

// One report -> one response per involved service (primary + secondary),
// each routed to its own nearest station. The response id is deterministic
// (`{reportID}_{serviceType}`), so a retried event can't create it twice and
// security rules can find a responder's response without a query.
exports.onReportCreated = onDocumentCreated("reports/{reportID}", async (event) => {
  const report = event.data.data();
  const ref = event.data.ref;
  const reportID = event.params.reportID;
  if (!report) return;

  if (!report.location || !SERVICE_TYPES.includes(report.incidentType)) {
    logger.warn("report unrouted", {reportID, reason: "missing location/type"});
    return ref.update({routingStatus: "unrouted"});
  }

  const types = [...new Set([report.incidentType, ...(report.secondaryServices || [])])]
      .filter((t) => SERVICE_TYPES.includes(t));

  const db = admin.firestore();
  // A dispatcher logging an SMS report picks the station themselves: keep it.
  const preset = report.serviceID || null;
  let primary = null;

  for (const type of types) {
    const isPrimary = type === report.incidentType;
    const station = isPrimary && preset ?
      {id: preset, distance: null} :
      await nearestStation(type, report.location);
    if (isPrimary) primary = station;

    try {
      await db.collection("responses").doc(`${reportID}_${type}`).create({
        reportID,
        userID: report.userID || "",
        serviceType: type,
        isPrimary,
        serviceID: station ? station.id : null,
        serviceDistanceMeters: station ? station.distance : null,
        routingStatus: station ? "routed" : "unrouted",
        assignedTo: null,
        status: "pending",
        responderNotes: [],
        responderAttachments: [],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } catch (err) {
      if (err.code !== 6) throw err; // 6 = ALREADY_EXISTS: a retry, nothing to do
    }
    if (!station) logger.warn("no active station", {reportID, type});
  }

  // Report-level routing fields describe the primary service only (kept so
  // existing dashboard code keeps working until it reads `responses`).
  await ref.update({
    ...(primary && !preset ? {serviceID: primary.id, serviceDistanceMeters: primary.distance} : {}),
    routingStatus: primary ? "routed" : "unrouted",
    routedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});
