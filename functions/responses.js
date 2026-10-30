const {onDocumentUpdated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");
const {STATUS_COPY, ASSIGNED_COPY, SERVICE_LABEL, pickLang} = require("./copy");

const RANK = {pending: 0, accepted: 1, dispatched: 2, onScene: 3, resolved: 4};

// Flip a responder back to available, but only if they have no other open
// response (safe even if multiple simultaneous cases are allowed later).
const releaseResponderIfIdle = async (responderID) => {
  if (!responderID) return;
  const db = admin.firestore();
  const snap = await db.collection("responses")
      .where("assignedTo", "==", responderID)
      .get();
  const hasOpenCase = snap.docs.some((d) => d.get("status") !== "resolved");
  if (hasOpenCase) return;

  const ref = db.collection("responders").doc(responderID);
  const doc = await ref.get();
  if (!doc.exists || doc.get("isAvailable") === true) return;
  await ref.update({isAvailable: true});
};

const PUSH_ANDROID = {
  priority: "high",
  notification: {channelId: "high_importance_channel", sound: "default"},
};

// The report's status is never written by clients. It is derived from its
// responses: `resolved` only once every response is resolved, otherwise the
// furthest-along response that is still open.
exports.onResponseWritten = onDocumentWritten("responses/{responseID}", async (event) => {
  const before = event.data.before.exists ? event.data.before.data() : null;
  const after = event.data.after.exists ? event.data.after.data() : null;
  const data = after || before;
  if (!data) return;
  if (before && after && before.status === after.status) return;

  const db = admin.firestore();
  const reportRef = db.collection("reports").doc(data.reportID);

  const next = await db.runTransaction(async (tx) => {
    const snap = await tx.get(db.collection("responses").where("reportID", "==", data.reportID));
    const report = await tx.get(reportRef);
    if (snap.empty || !report.exists) return null;

    const statuses = snap.docs.map((d) => d.get("status") || "pending");
    const open = statuses.filter((s) => s !== "resolved");
    const status = open.length === 0 ?
      "resolved" :
      open.reduce((a, b) => (RANK[a] >= RANK[b] ? a : b));

    if (report.get("status") === status) return status;
    tx.update(reportRef, {
      status,
      resolvedAt: status === "resolved" ?
        admin.firestore.FieldValue.serverTimestamp() :
        admin.firestore.FieldValue.delete(), // report was reopened
    });
    return status;
  });

  if (next === "resolved") {
    await admin.database().ref(`activeReports/${data.reportID}`).remove();
  }
});

// A response moving to a new status: clean up that responder's location and
// tell the reporter which service moved.
exports.onResponseStatusChange = onDocumentUpdated("responses/{responseID}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.status === after.status) return;

  logger.info("response status", {
    eventId: event.id,
    responseID: event.params.responseID,
    from: before.status,
    to: after.status,
  });

  if (after.status === "resolved" && after.assignedTo) {
    await admin.database().ref(`responderLocations/${after.reportID}/${after.assignedTo}`).remove();
    await releaseResponderIfIdle(after.assignedTo);
  }

  const copy = STATUS_COPY[after.status];
  if (!copy || !after.userID) return; // SMS reports logged by a dispatcher may have no app user

  const userSnap = await admin.firestore().collection("users").doc(after.userID).get();
  const user = userSnap.data();
  if (user?.isDeactivated || !user?.fcmToken) return;

  const lang = pickLang(user);
  const label = SERVICE_LABEL[after.serviceType]?.[lang];
  const text = copy[lang];

  try {
    await admin.messaging().send({
      token: user.fcmToken,
      notification: {title: label ? `${label}: ${text.title}` : text.title, body: text.body},
      data: {
        type: "reportStatus",
        reportID: after.reportID,
        serviceType: after.serviceType,
        status: after.status,
      },
      android: PUSH_ANDROID,
      apns: {payload: {aps: {"sound": "default", "content-available": 1}}},
    });
  } catch (err) {
    if (err.code === "messaging/registration-token-not-registered") {
      await userSnap.ref.update({fcmToken: admin.firestore.FieldValue.delete()});
    } else {
      throw err;
    }
  }
});

// An operator (re)assigning a responder on the dashboard.
exports.onResponseAssigned = onDocumentUpdated("responses/{responseID}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  const responderID = after.assignedTo;
  if (before.assignedTo === responderID) return;
  await releaseResponderIfIdle(after.assignedTo);

  // The previous responder is no longer on this case: stop showing their pin.
  if (before.assignedTo) {
    await admin.database().ref(`responderLocations/${after.reportID}/${before.assignedTo}`).remove();
  }
  if (!responderID || after.status === "resolved") return;

  logger.info("response assigned", {
    eventId: event.id,
    responseID: event.params.responseID,
    responderID,
  });

  const responderRef = admin.firestore().collection("responders").doc(responderID);
  const responder = (await responderRef.get()).data();
  if (!responder || responder.isActive === false || !responder.fcmToken) return;

  try {
    await admin.messaging().send({
      token: responder.fcmToken,
      notification: ASSIGNED_COPY[pickLang(responder)],
      data: {type: "reportAssigned", reportID: after.reportID, responseID: event.params.responseID},
      android: PUSH_ANDROID,
      apns: {headers: {"apns-priority": "10"}, payload: {aps: {sound: "default"}}},
    });
  } catch (err) {
    if (err.code === "messaging/registration-token-not-registered") {
      await responderRef.update({fcmToken: admin.firestore.FieldValue.delete()});
    } else {
      throw err;
    }
  }
});
