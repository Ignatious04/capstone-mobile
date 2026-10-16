const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

Object.assign(exports, require("./audit"));

// Push text per language. Anything other than "fil" falls back to English
// (covers users who never saved a language).
const STATUS_COPY = {
  accepted: {
    en: {title: "Report accepted", body: "A responder has accepted your report."},
    fil: {title: "Tinanggap ang report", body: "Tinanggap ng isang responder ang iyong report."},
  },
  dispatched: {
    en: {title: "Help is on the way", body: "A responder has been dispatched to your location."},
    fil: {title: "Papunta na ang tulong", body: "May responder nang ipinadala sa iyong lokasyon."},
  },
  onScene: {
    en: {title: "Responder on scene", body: "A responder has arrived at your location."},
    fil: {title: "Nasa lugar na ang responder", body: "Dumating na ang responder sa iyong lokasyon."},
  },
  resolved: {
    en: {title: "Report resolved", body: "Your report has been marked as resolved."},
    fil: {title: "Nalutas na ang report", body: "Nalutas na ang iyong report."},
  },
  pending: {
    en: {title: "Report reopened", body: "Your report is back in the queue for review."},
    fil: {title: "Muling binuksan ang report", body: "Bumalik sa pila ang iyong report para sa pagsusuri."},
  },
};

const ASSIGNED_COPY = {
  en: {title: "New case assigned", body: "You have been assigned a new report. Open the app to view it."},
  fil: {title: "May bagong case na itinalaga", body: "May bagong report na itinalaga sa iyo. Buksan ang app para makita ito."},
};

const VERIFICATION_COPY = {
  approved: {
    en: {title: "Account verified", body: "Your account has been approved."},
    fil: {title: "Na-verify na ang account", body: "Naaprubahan na ang iyong account."},
  },
  rejected: {
    en: {title: "Verification needs attention", body: "Open the app to see why and what to do next."},
    fil: {title: "Kailangan ng aksyon sa verification", body: "Buksan ang app para makita ang dahilan at kung ano ang susunod na gagawin."},
  },
};

const pickLang = (doc) => (doc?.languageCode === "fil" ? "fil" : "en");

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
      notification: ASSIGNED_COPY[pickLang(responder)],
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
  const text = copy[pickLang(userData)];

  try {
    await admin.messaging().send({
      token,
      notification: {title: text.title, body: text.body},
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

  const entry = VERIFICATION_COPY[after.verificationStatus];
  if (!entry || !after.fcmToken) return;
  const copy = entry[pickLang(after)];

  await admin.messaging().send({
    token: after.fcmToken,
    notification: copy,
    data: {type: "verification", status: after.verificationStatus},
  });
});
