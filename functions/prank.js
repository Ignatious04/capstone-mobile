const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {logger} = require("firebase-functions");
const admin = require("firebase-admin");
const {pickLang} = require("./copy");

// Must match the field the dashboard writes on the report doc.
const PRANK_FIELD = "isPrank";

const SUSPENSION_DAYS = [0, 7, 30]; // strike 1 = warning only, 2 = 7d, 3 = 30d
const BAN_AT = 4;

const PRANK_COPY = {
  warning: {
    en: {title: "Prank report warning", body: "One of your reports was marked as a prank. Repeated prank reports lead to suspension of online reporting."},
    fil: {title: "Babala: prank na report", body: "Ang isa sa iyong mga report ay minarkahang prank. Ang paulit-ulit nito ay magreresulta sa pagsuspinde ng online na pag-uulat."},
  },
  suspended: {
    en: {title: "Online reporting suspended", body: "Your account was flagged for a prank report. You can still call emergency services."},
    fil: {title: "Naka-suspend ang online na pag-uulat", body: "Na-flag ang iyong account dahil sa prank na report. Maaari ka pa ring tumawag sa mga serbisyong pang-emergency."},
  },
};

exports.onPrankFlagChange = onDocumentUpdated("reports/{reportID}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!!before[PRANK_FIELD] === !!after[PRANK_FIELD] || !after.userID) return;

  const db = admin.firestore();
  const userRef = db.collection("users").doc(after.userID);
  const auditRef = db.collection("audit_logs").doc(event.id);
  const flagged = !!after[PRANK_FIELD];

  let result = null;
  try {
    result = await db.runTransaction(async (tx) => {
      const snap = await tx.get(userRef);
      if (!snap.exists) return null;

      const strikes = Math.max(0, (snap.get("prankStrikes") || 0) + (flagged ? 1 : -1));
      const days = strikes > 0 && strikes < BAN_AT ? SUSPENSION_DAYS[strikes - 1] : 0;

      // tx.create throws ALREADY_EXISTS on a retried event, which aborts the
      // whole transaction, so a duplicate delivery can't double-count a strike.
      tx.create(auditRef, {
        action: flagged ? "moderation.prank_strike_added" : "moderation.prank_strike_removed",
        category: "moderation",
        actorId: null,
        actorType: "system",
        targetType: "user",
        targetId: after.userID,
        metadata: {reportID: event.params.reportID, strikes},
        source: "server",
        authType: "system",
        eventId: event.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      tx.update(userRef, {
        prankStrikes: strikes,
        reportingBanned: strikes >= BAN_AT,
        reportingSuspendedUntil: days > 0 ? Date.now() + days * 86400000 : null,
      });
      return {strikes, days, user: snap.data()};
    });
  } catch (err) {
    if (err.code === 6) return; // ALREADY_EXISTS: duplicate delivery
    throw err;
  }

  if (!result || !flagged || !result.user.fcmToken) return;
  const kind = result.strikes === 1 ? "warning" : "suspended";
  try {
    await admin.messaging().send({
      token: result.user.fcmToken,
      notification: PRANK_COPY[kind][pickLang(result.user)],
      data: {type: "prank", strikes: String(result.strikes)},
      android: {priority: "high", notification: {channelId: "high_importance_channel", sound: "default"}},
    });
  } catch (err) {
    if (err.code === "messaging/registration-token-not-registered") {
      await userRef.update({fcmToken: admin.firestore.FieldValue.delete()});
    } else {
      logger.error("prank push failed", {err: err.message});
    }
  }
});
