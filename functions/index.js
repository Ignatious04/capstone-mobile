const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
admin.initializeApp();

Object.assign(exports, require("./audit"));
Object.assign(exports, require("./routing"));
Object.assign(exports, require("./responses"));

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

const CONSENT_COPY = {
  approved: {
    en: {title: "Guardian consent received", body: "Your guardian approved your account. You can now use the features they allowed."},
    fil: {title: "Natanggap ang pahintulot ng tagapag-alaga", body: "Inaprubahan ng iyong tagapag-alaga ang iyong account. Magagamit mo na ang mga feature na pinayagan nila."},
  },
  revoked: {
    en: {title: "Guardian consent withdrawn", body: "Your guardian withdrew consent. Some features that store personal data are limited."},
    fil: {title: "Binawi ang pahintulot ng tagapag-alaga", body: "Binawi ng iyong tagapag-alaga ang pahintulot. May mga limitasyon sa ilang feature na nag-iimbak ng personal na datos."},
  },
};

const {pickLang} = require("./copy");

const {logger} = require("firebase-functions");

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

exports.onConsentChange = onDocumentUpdated("users/{uid}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (before.consentStatus === after.consentStatus) return;

  const entry = CONSENT_COPY[after.consentStatus];
  if (!entry || after.isDeactivated || !after.fcmToken) return;
  const copy = entry[pickLang(after)];

  try {
    await admin.messaging().send({
      token: after.fcmToken,
      notification: {title: copy.title, body: copy.body},
      data: {type: "consent", status: after.consentStatus},
      android: {
        priority: "high",
        notification: {channelId: "high_importance_channel", sound: "default"},
      },
      apns: {payload: {aps: {"sound": "default", "content-available": 1}}},
    });
  } catch (err) {
    if (err.code === "messaging/registration-token-not-registered") {
      await event.data.after.ref.update({fcmToken: admin.firestore.FieldValue.delete()});
    } else {
      throw err;
    }
  }
});

const {onRequest, onCall, HttpsError} = require("firebase-functions/v2/https");
const crypto = require("crypto");
const NOTICE_VERSION = "2026-10-v1";

const {defineSecret} = require("firebase-functions/params");
const nodemailer = require("nodemailer");

const SMTP_USER = defineSecret("SMTP_USER");
const SMTP_PASS = defineSecret("SMTP_PASS");

function mailer() {
  return nodemailer.createTransport({
    host: "smtp.gmail.com",
    port: 465,
    secure: true,
    auth: {user: SMTP_USER.value(), pass: SMTP_PASS.value()},
  });
}

const PH_OFFSET_MS = 8 * 60 * 60 * 1000; // Philippines is UTC+8, no daylight saving

function isMinor(ms) {
  if (!ms) return false;
  // Shift both dates to Philippine time, then read them with the UTC getters.
  const dob = new Date(ms + PH_OFFSET_MS);
  const now = new Date(Date.now() + PH_OFFSET_MS);
  let age = now.getUTCFullYear() - dob.getUTCFullYear();
  const m = now.getUTCMonth() - dob.getUTCMonth();
  if (m < 0 || (m === 0 && now.getUTCDate() < dob.getUTCDate())) age--;
  return age < 18;
}

const RELATIONSHIP_LABELS = {
  mother: "mother",
  father: "father",
  grandparent: "grandparent",
  legalGuardian: "legal guardian",
  otherRelative: "relative",
};

const escapeHtml = (s = "") =>
  String(s).replace(/[&<>"']/g, (c) => (
    {"&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;"}[c]
  ));

const CONSENT_COOLDOWN_MS = 60 * 60 * 1000; // 1 hour between sends
const MAX_CONSENT_SENDS = 5;

async function sendConsentRequest(uid, user) {
  if (!user.guardianContact || !user.guardianContact.includes("@")) {
    logger.warn("consent request skipped: no guardian email", {uid});
    return;
  }
  const db = admin.firestore();
  const childName = [user.firstName, user.lastName].filter(Boolean).join(" ").trim();
  const relationship = RELATIONSHIP_LABELS[user.guardianRelationship] || "guardian";

  // Kill any older links so only the newest one works.
  const old = await db.collection("consentRequests")
      .where("uid", "==", uid).where("used", "==", false).get();
  const batch = db.batch();
  old.docs.forEach((d) => batch.update(d.ref, {used: true}));

  const token = crypto.randomBytes(24).toString("hex");
  batch.set(db.collection("consentRequests").doc(token), {
    uid, used: false, childName, relationship,
    expiresAt: Date.now() + 7 * 24 * 60 * 60 * 1000,
  });
  await batch.commit();

  const link = `https://capstone-project-ae71f.web.app/consent.html?t=${token}`;
  await mailer().sendMail({
    from: `"Saup Angeles" <${SMTP_USER.value()}>`,
    to: user.guardianContact,
    subject: `Guardian consent request for ${childName}`,
    html: `<p>Hello ${escapeHtml(user.guardianName)},</p>
<p><b>${escapeHtml(childName)}</b> registered for Saup Angeles and listed you as their
<b>${relationship}</b>. Because they are under 18, we need your consent before we store
their personal data.</p>
<p><a href="${link}">Review and respond</a> (this link expires in 7 days).</p>
<p>If you don't know this person, you can ignore this email.</p>`,
  });
}

exports.onSetupComplete = onDocumentUpdated(
    {document: "users/{uid}", secrets: [SMTP_USER, SMTP_PASS]},
    async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      if (before.isSetup || !after.isSetup) return;
      if (!isMinor(after.birthDate) || after.consentStatus) return;

      const ref = event.data.after.ref;
      const claimed = await admin.firestore().runTransaction(async (tx) => {
        const snap = await tx.get(ref);
        if (snap.data().consentStatus) return false; // another run already got here
        tx.update(ref, {
          consentStatus: "pending",
          consentLastSentAt: Date.now(),
          consentSendCount: 1,
        });
        return true;
      });
      if (!claimed) return;
      await sendConsentRequest(event.params.uid, after);
    });

exports.resendGuardianConsent = onCall({secrets: [SMTP_USER, SMTP_PASS]}, async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "unauthenticated");

  const db = admin.firestore();
  const ref = db.collection("users").doc(uid);
  let user;

  // A transaction so a double-tap can't slip two sends past the cooldown.
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    user = snap.data();
    if (!user || user.consentStatus !== "pending") {
      throw new HttpsError("failed-precondition", "no-pending-request");
    }
    const count = user.consentSendCount || 0;
    if (count >= MAX_CONSENT_SENDS) {
      throw new HttpsError("resource-exhausted", "limit-reached");
    }
    if (Date.now() - (user.consentLastSentAt || 0) < CONSENT_COOLDOWN_MS) {
      throw new HttpsError("resource-exhausted", "cooldown");
    }
    tx.update(ref, {consentLastSentAt: Date.now(), consentSendCount: count + 1});
  });

  await sendConsentRequest(uid, user);
  return {ok: true};
});

const TOKEN_RE = /^[a-f0-9]{48}$/; // crypto.randomBytes(24).toString("hex")
const ALLOWED_PURPOSES = ["accountData", "locationStorage", "reportHistory", "medicalInfo"];

// consent.html calls this first, to show who the consent is for.
exports.getConsentRequest = onRequest({cors: true}, async (req, res) => {
  const token = String(req.query.t || "");
  if (!TOKEN_RE.test(token)) return res.status(400).json({error: "invalid"});
  const snap = await admin.firestore().collection("consentRequests").doc(token).get();
  const d = snap.data();
  if (!d || d.used || d.expiresAt < Date.now()) return res.status(400).json({error: "invalid"});
  res.json({childName: d.childName, relationship: d.relationship, noticeVersion: NOTICE_VERSION});
});

exports.recordGuardianConsent = onRequest({cors: true}, async (req, res) => {
  if (req.method !== "POST") return res.status(405).send("POST only");
  const {token, guardianName, purposes} = req.body || {};
  const granted = Array.isArray(purposes) ? purposes.filter((p) => ALLOWED_PURPOSES.includes(p)) : [];
  if (!TOKEN_RE.test(token || "") || typeof guardianName !== "string" ||
    !guardianName.trim() || granted.length === 0) {
    return res.status(400).send("Invalid request");
  }

  const db = admin.firestore();
  const reqRef = db.collection("consentRequests").doc(token);
  try {
    await db.runTransaction(async (tx) => {
      const reqSnap = await tx.get(reqRef);
      const d = reqSnap.data();
      if (!d || d.used || d.expiresAt < Date.now()) throw new Error("invalid");
      const userRef = db.collection("users").doc(d.uid);
      const userSnap = await tx.get(userRef);
      if (!userSnap.exists || userSnap.data().consentStatus !== "pending") throw new Error("invalid");

      tx.set(userRef.collection("consents").doc(), {
        guardianName: guardianName.trim().slice(0, 100),
        purposes: granted,
        noticeVersion: NOTICE_VERSION,
        grantedAt: Date.now(),
      });
      tx.update(userRef, {consentStatus: "approved", consentPurposes: granted});
      tx.update(reqRef, {used: true});
    });
  } catch (e) {
    return res.status(400).send("Invalid or expired link");
  }
  res.send("ok");
});


