import 'package:capstone/core/shared/models/notification_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/repositories/notification_history_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationHistoryRepositoryProvider = Provider<NotificationHistoryRepository>(
  (ref) => NotificationHistoryRepository(),
);

final notificationHistoryProvider = NotifierProvider<NotificationHistoryNotifier, List<NotificationModel>>(
  NotificationHistoryNotifier.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationHistoryProvider);
  return notifications.where((n) => !n.isRead).length;
});

class NotificationHistoryNotifier extends Notifier<List<NotificationModel>> {
  @override
  List<NotificationModel> build() {
    // Reload whenever the signed-in user changes (login/logout/switch account),
    // since build() itself only runs once for the lifetime of the provider.
    ref.listen(authStateProvider, (previous, next) => _load());
    _load();
    return [];
  }

  Future<void> _load() async {
    final userID = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userID == null) {
      state = [];
      return;
    }

    state = await ref.read(notificationHistoryRepositoryProvider).getAll(userID);
  }

  Future<void> add(NotificationModel notification) async {
    final userID = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userID == null) return;

    if (state.any((n) => n.id == notification.id)) return;

    await ref.read(notificationHistoryRepositoryProvider).add(userID, notification);
    state = [notification, ...state];
  }

  Future<void> markAsRead(String notificationID) async {
    final userID = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userID == null) return;

    await ref.read(notificationHistoryRepositoryProvider).markAsRead(userID, notificationID);
    state = state.map((n) => n.id == notificationID ? n.copyWith(isRead: true) : n).toList();
  }

  Future<void> markAllAsRead() async {
    final userID = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userID == null) return;

    await ref.read(notificationHistoryRepositoryProvider).markAllAsRead(userID);
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }

  Future<void> delete(String notificationID) async {
    final userID = ref.read(firebaseAuthProvider).currentUser?.uid;
    if (userID == null) return;

    await ref.read(notificationHistoryRepositoryProvider).delete(userID, notificationID);
    state = state.where((n) => n.id != notificationID).toList();
  }
}
