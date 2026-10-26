const {
  onDocumentCreatedWithAuthContext,
  onDocumentUpdatedWithAuthContext,
  onDocumentDeletedWithAuthContext,
} = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
const {logger} = require("firebase-functions");

// Never logged at all (noise).
const IGNORED = new Set(["fcmToken", "languageCode", "updatedAt", "deactivatedAt", "createdAt"]);

// Only these get before/after values in the log. Every other changed field
// (ID number, address, medical info, URLs...) is logged as {changed: true}.
const TRACKED_VALUES = new Set([
  "status", "assignedTo", "priority",
  "isDeactivated", "isContactNumberVerified", "isSetup", "verificationStatus",
  "rejectionReason", "isActive", "isAvailable",
]);

const diffFields = (before, after) => {
  const changes = {};
  const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
  for (const key of keys) {
    if (IGNORED.has(key)) continue;
    if (JSON.stringify(before[key]) === JSON.stringify(after[key])) continue;
    changes[key] = TRACKED_VALUES.has(key) ?
      {from: before[key] ?? null, to: after[key] ?? null} :
      {changed: true};
  }
  return changes;
};

const resolveActor = async (event) => {
  if (event.authType === "service_account" || event.authType === "system") {
    return {actorId: null, actorType: "system"};
  }
  const id = event.authId || null;
  if (!id) return {actorId: null, actorType: "unknown"};

  const db = admin.firestore();
  if ((await db.collection("responders").doc(id).get()).exists) {
    return {actorId: id, actorType: "responder"};
  }
  if ((await db.collection("users").doc(id).get()).exists) {
    return {actorId: id, actorType: "user"};
  }
  return {actorId: id, actorType: "staff"}; // dashboard operator/admin
};

const writeAudit = async (event, entry) => {
  try {
    // Doc ID = event ID, so a retried or duplicate delivery can't double-log.
    await admin.firestore().collection("audit_logs").doc(event.id).create({
      ...entry,
      source: "server",
      authType: event.authType || "unknown",
      eventId: event.id,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    if (err.code === 6) return; // ALREADY_EXISTS
    logger.error("audit write failed", {eventId: event.id, err: err.message});
    throw err;
  }
};

// ---------- reports ----------
exports.auditReportCreated = onDocumentCreatedWithAuthContext(
    "reports/{reportID}", async (event) => {
      const d = event.data.data();
      const clientTime = d.createdAt?.toDate?.() ?? null;
      const serverTime = event.time ? new Date(event.time) : new Date();
      const clockSkewSeconds = clientTime ?
      Math.round((serverTime - clientTime) / 1000) : null;

      await writeAudit(event, {
        action: "report.created",
        category: "report",
        ...(await resolveActor(event)),
        targetType: "report",
        targetId: event.params.reportID,
        metadata: {
          referenceNumber: d.referenceNumber,
          reportType: d.reportType,
          incidentType: d.incidentType || null,
          priority: d.priority || null,
          policeConcernType: d.policeConcernType || null,
          attachmentCount: (d.attachments || []).length,
          victimCount: (d.victims || []).length,
          guidanceAnswerCount: (d.guidanceAnswers || []).length,
          hasLocation: !!d.location,
          locationAccuracy: d.locationAccuracy ?? null,
          hasOriginalGps: !!d.originalGpsLocation,
          clientCreatedAt: clientTime ? clientTime.toISOString() : null,
          clockSkewSeconds,
        },
      });
    });

exports.auditReportUpdated = onDocumentUpdatedWithAuthContext(
    "reports/{reportID}", async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      const changes = diffFields(before, after);
      if (Object.keys(changes).length === 0) return;

      let action = "report.updated";
      if (changes.status) action = "report.status_changed";
      else if (changes.assignedTo) action = "report.assignment_changed";
      else if (changes.priority) action = "report.priority_changed";

      await writeAudit(event, {
        action,
        category: "report",
        ...(await resolveActor(event)),
        targetType: "report",
        targetId: event.params.reportID,
        changes,
        metadata: {referenceNumber: after.referenceNumber, reporterID: after.userID},
      });
    });

// ---------- responses (one service's part of a report) ----------
// Responder and operator actions (assign, dispatch, on scene, resolve) now
// land here instead of on the report, so they are audited here.
exports.auditResponseCreated = onDocumentCreatedWithAuthContext(
    "responses/{responseID}", async (event) => {
      const d = event.data.data();
      await writeAudit(event, {
        action: "response.created",
        category: "report",
        ...(await resolveActor(event)),
        targetType: "response",
        targetId: event.params.responseID,
        metadata: {
          reportID: d.reportID,
          serviceType: d.serviceType,
          isPrimary: !!d.isPrimary,
          serviceID: d.serviceID || null,
        },
      });
    });

exports.auditResponseUpdated = onDocumentUpdatedWithAuthContext(
    "responses/{responseID}", async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      const changes = diffFields(before, after);
      if (Object.keys(changes).length === 0) return;

      let action = "response.updated";
      if (changes.status) action = "response.status_changed";
      else if (changes.assignedTo) action = "response.assignment_changed";

      await writeAudit(event, {
        action,
        category: "report",
        ...(await resolveActor(event)),
        targetType: "response",
        targetId: event.params.responseID,
        changes,
        metadata: {reportID: after.reportID, serviceType: after.serviceType, reporterID: after.userID},
      });
    });

exports.auditReportDeleted = onDocumentDeletedWithAuthContext(
    "reports/{reportID}", async (event) => {
      const d = event.data.data();
      await writeAudit(event, {
        action: "report.deleted",
        category: "report",
        ...(await resolveActor(event)),
        targetType: "report",
        targetId: event.params.reportID,
        metadata: {referenceNumber: d.referenceNumber, reporterID: d.userID},
      });
    });

// ---------- users ----------
exports.auditUserCreated = onDocumentCreatedWithAuthContext(
    "users/{userID}", async (event) => {
      await writeAudit(event, {
        action: "account.created",
        category: "account",
        ...(await resolveActor(event)),
        targetType: "user",
        targetId: event.params.userID,
        metadata: {},
      });
    });

exports.auditUserUpdated = onDocumentUpdatedWithAuthContext(
    "users/{userID}", async (event) => {
      const before = event.data.before.data();
      const after = event.data.after.data();
      const changes = diffFields(before, after);
      if (Object.keys(changes).length === 0) return;

      let action = "user.updated";
      if (changes.isDeactivated) {
        action = after.isDeactivated ? "account.deactivated" : "account.reactivated";
      } else if (changes.verificationStatus) {
        action = "account.verification_changed";
      } else if (changes.isSetup && after.isSetup) {
        action = "account.setup_completed";
      } else if (changes.isContactNumberVerified) {
        action = after.isContactNumberVerified ?
        "account.phone_verified" : "account.phone_unverified";
      }

      await writeAudit(event, {
        action,
        category: "account",
        ...(await resolveActor(event)),
        targetType: "user",
        targetId: event.params.userID,
        changes,
        metadata: {},
      });
    });

// ---------- responders ----------
exports.auditResponderCreated = onDocumentCreatedWithAuthContext(
    "responders/{responderID}", async (event) => {
      const d = event.data.data();
      await writeAudit(event, {
        action: "responder.created",
        category: "responder",
        ...(await resolveActor(event)),
        targetType: "responder",
        targetId: event.params.responderID,
        metadata: {department: d.department || null, role: d.role || null},
      });
    });

exports.auditResponderUpdated = onDocumentUpdatedWithAuthContext(
    "responders/{responderID}", async (event) => {
      const changes = diffFields(event.data.before.data(), event.data.after.data());
      if (Object.keys(changes).length === 0) return;
      await writeAudit(event, {
        action: changes.isActive ? "responder.active_changed" : "responder.updated",
        category: "responder",
        ...(await resolveActor(event)),
        targetType: "responder",
        targetId: event.params.responderID,
        changes,
        metadata: {},
      });
    });

exports.auditResponderDeleted = onDocumentDeletedWithAuthContext(
    "responders/{responderID}", async (event) => {
      await writeAudit(event, {
        action: "responder.deleted",
        category: "responder",
        ...(await resolveActor(event)),
        targetType: "responder",
        targetId: event.params.responderID,
        metadata: {},
      });
    });
