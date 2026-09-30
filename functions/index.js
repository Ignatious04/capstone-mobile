const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

const STATUS_COPY = {
  accepted: {title: "Report accepted", body: "A responder has accepted your report."},
  dispatched: {title: "Help is on the way", body: "A responder has been dispatched to your location."},
  onScene: {title: "Responder on scene", body: "A responder has arrived at your location."},
  resolved: {title: "Report resolved", body: "Your report has been marked as resolved."},
  pending: {title: "Report reopened", body: "Your report is back in the queue for review."},
};

const {logger} = require("firebase-functions");

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
    });
  } catch (err) {
    if (err.code === "messaging/registration-token-not-registered") {
      await userSnap.ref.update({fcmToken: admin.firestore.FieldValue.delete()});
    } else {
      throw err;
    }
  }
});
