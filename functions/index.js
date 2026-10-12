const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

Object.assign(exports, require("./audit"));

const STATUS_COPY = {
  accepted: {title: "Report accepted", body: "A responder has accepted your report."},
  dispatched: {title: "Help is on the way", body: "A responder has been dispatched to your location."},
  onScene: {title: "Responder on scene", body: "A responder has arrived at your location."},
  resolved: {title: "Report resolved", body: "Your report has been marked as resolved."},
  pending: {title: "Report reopened", body: "Your report is back in the queue for review."},
};

const {logger} = require("firebase-functions");

exports.onReportAssigned = onDocumentUpdated("reports/{reportID}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();

  const responderID = after.assignedTo;
  if (!responderID || before.assignedTo === responderID) return;
  if (after.status === "resolved") return;

  logger.info("report assigned", {
    eventId: event.id,
    reportID: event.params.reportID,
    responderID,
  });

  const responderRef = admin.firestore().collection("responders").doc(responderID);
  const responderSnap = await responderRef.get();
  const responder = responderSnap.data();
  if (!responder || responder.isActive === false) return;

  const token = responder.fcmToken;
  if (!token) return;

  try {
    await admin.messaging().send({
      token,
      notification: {
        title: "New case assigned",
        body: "You have been assigned a new report. Open the app to view it.",
      },
      data: {type: "reportAssigned", reportID: event.params.reportID},
      android: {
        priority: "high",
        notification: {channelId: "high_importance_channel", sound: "default"},
      },
      apns: {
        headers: {"apns-priority": "10"},
        payload: {aps: {sound: "default"}},
      },
    });
  } catch (err) {
    if (err.code === "messaging/registration-token-not-registered") {
      await responderRef.update({fcmToken: admin.firestore.FieldValue.delete()});
    } else {
      throw err;
    }
  }
});

exports.onReportStatusChange = onDocumentUpdated("reports/{reportID}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();

  logger.info("report update", {
    eventId: event.id,
    reportID: event.params.reportID,
    beforeStatus: before.status,
    afterStatus: after.status,
    updateTime: event.data.after.updateTime?.toDate().toISOString(),
  });

  if (before.status === after.status) return;

  if (after.status === "resolved") {
    await admin.database().ref(`responderLocations/${event.params.reportID}`).remove();
  }

  const copy = STATUS_COPY[after.status];
  if (!copy) return;

  const userSnap = await admin.firestore().collection("users").doc(after.userID).get();
  const userData = userSnap.data();
  if (userData?.isDeactivated) return;
  const token = userData?.fcmToken;
  if (!token) return;

  try {
    await admin.messaging().send({
      token,
      notification: {title: copy.title, body: copy.body},
      data: {type: "reportStatus", reportID: event.params.reportID, status: after.status},
      android: {
        priority: "high",
        notification: {channelId: "high_importance_channel", sound: "default"},
      },
      apns: {payload: {aps: {sound: "default"}}},
    });
  } catch (err) {
    if (err.code === "messaging/registration-token-not-registered") {
      await userSnap.ref.update({fcmToken: admin.firestore.FieldValue.delete()});
    } else {
      throw err;
    }
  }
});

exports.onVerificationChange = onDocumentUpdated("users/{uid}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.verificationStatus === after.verificationStatus) return;

  const copy = {
    approved: {title: "Account verified", body: "Your account has been approved."},
    rejected: {title: "Verification needs attention", body: "Open the app to see why and what to do next."},
  }[after.verificationStatus];
  if (!copy || !after.fcmToken) return;

  await admin.messaging().send({
    token: after.fcmToken,
    notification: copy,
    data: {type: "verification", status: after.verificationStatus},
  });
});
