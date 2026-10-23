const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");

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

exports.onReportCreated = onDocumentCreated("reports/{reportID}", async (event) => {
  const report = event.data.data();
  const ref = event.data.ref;
  if (!report || report.serviceID) return; // idempotent

  const unrouted = (reason) => {
    logger.warn("report unrouted", {reportID: event.params.reportID, reason});
    return ref.update({routingStatus: "unrouted"});
  };

  if (!report.location || !report.incidentType) return unrouted("missing location/type");

  const snap = await admin.firestore()
      .collection("emergencyServices")
      .where("type", "==", report.incidentType)
      .where("isActive", "==", true)
      .get();

  let best = null;
  let bestDist = Infinity;
  snap.forEach((doc) => {
    const loc = doc.get("location");
    if (!loc) return;
    const d = distanceMeters(report.location, loc);
    if (d < bestDist) {
      best = doc;
      bestDist = d;
    }
  });

  if (!best) return unrouted("no active station");

  await ref.update({
    serviceID: best.id,
    serviceDistanceMeters: Math.round(bestDist),
    routingStatus: "routed",
    routedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});
