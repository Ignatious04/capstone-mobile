import 'package:flutter/widgets.dart';

/// Prevents an async action (submit, confirm, etc.) from running again
/// while a previous run is still in progress.
///
/// Works on both State and ConsumerState.
mixin SubmitGuardMixin<T extends StatefulWidget> on State<T> {
  bool _isBusy = false;

  /// True while a guarded action is running. Use it to disable buttons.
  bool get isBusy => _isBusy;

  /// Runs [action] unless another guarded action is already running.
  /// Extra calls are ignored. The flag resets when [action] finishes,
  /// returns early, or throws.
  Future<void> guarded(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true); // sets the flag synchronously
    try {
      await action();
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }
}