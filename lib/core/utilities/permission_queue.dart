Future<void> _tail = Future.value();

/// Runs system permission prompts one at a time; a second prompt
/// would cancel the first and come back as "denied".
Future<T> runPermissionRequest<T>(Future<T> Function() request) {
  final result = _tail.then((_) => request());
  _tail = result.then((_) {}, onError: (_) {});
  return result;
}