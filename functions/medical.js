const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const {isMinor} = require("./age");

// `pending` has no assignee; `resolved` ends access.
const OPEN_STATUSES = new Set(["accepted", "dispatched", "onScene"]);

exports.getReporterMedicalInfo = onCall(async (request) => {
  const uid = request.auth?.uid;
  const reportID = request.data?.reportID;
  if (!uid) throw new HttpsError("unauthenticated", "sign-in-required");
  if (typeof reportID !== "string" || !reportID) {
    throw new HttpsError("invalid-argument", "report-required");
  }

  const db = admin.firestore();
  const [responderSnap, responseSnap, reportSnap] = await Promise.all([
    db.collection("responders").doc(uid).get(),
    // Deterministic id: only the *medical* response of this report.
    db.collection("responses").doc(`${reportID}_medical`).get(),
    db.collection("reports").doc(reportID).get(),
  ]);

  // 1. Caller is the assigned responder, and that response is still open.
  if (!responderSnap.exists || responderSnap.get("isActive") === false ||
      !responseSnap.exists || responseSnap.get("assignedTo") !== uid ||
      !OPEN_STATUSES.has(responseSnap.get("status"))) {
    throw new HttpsError("permission-denied", "not-assigned-or-closed");
  }

  // Only the reporter's own info, and only when the report is about them.
  // (The !userID guard matters: an empty id makes .doc("") throw.)
  const userID = responseSnap.get("userID");
  if (!userID || !reportSnap.exists || reportSnap.get("reportedForSelf") !== true ||
      reportSnap.get("userID") !== userID) {
    return {available: false};
  }
  const userSnap = await db.collection("users").doc(userID).get();
  if (!userSnap.exists) return {available: false};
  const user = userSnap.data();

  // 2. Reporter opted in; minors also need the guardian's medicalInfo consent
  //    (mirrors UserModel.canEditMedicalInfo).
  const consented = user.medicalSharingConsent === true &&
    (!isMinor(user.birthDate) ||
      (user.consentStatus === "approved" &&
       (user.consentPurposes || []).includes("medicalInfo")));
  if (!consented) return {available: false}; // don't reveal why

  // 3. Minimum necessary. Add vaccination fields only if you can justify them.
  const info = {
    bloodType: user.bloodType || "",
    height: user.height || 0,
    weight: user.weight || 0,
  };
  if (!info.bloodType && !info.height && !info.weight) return {available: false};

  // 4. Fail closed: if the audit write throws, no data is returned.
  const logRef = db.collection("audit_logs").doc();
  await logRef.set({
    eventId: logRef.id,
    action: "responder.medical_info_viewed",
    category: "responder",
    actorId: uid,
    actorType: "responder",
    authType: "callable",
    targetType: "user",
    targetId: userSnap.id,
    metadata: {reportID, fields: Object.keys(info)},
    source: "server",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {available: true, info};
});
