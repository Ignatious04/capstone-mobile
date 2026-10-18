/// Firestore acknowledges writes from the server. Offline, the future never
/// completes (the write just queues), so we cap the wait.
const kReportWriteTimeout = Duration(seconds: 10);

/// Per-file cap for report attachment uploads.
const kUploadTimeout = Duration(seconds: 30);
