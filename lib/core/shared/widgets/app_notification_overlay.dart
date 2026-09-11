import 'package:capstone/core/shared/providers/app_notification_provider.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppNotificationOverlay extends ConsumerWidget {
  const AppNotificationOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(appNotificationProvider);

    return Stack(
      children: [
        child,

        Positioned(
          top: MediaQuery.paddingOf(context).top + 125,
          right: 20,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            reverseDuration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              final slideAnimation = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation);

              return SlideTransition(
                position: slideAnimation,
                child: child,
              );
            },
            child: notification == null
                ? const SizedBox(
                    key: ValueKey('empty'),
                  )
                : Material(
                    key: ValueKey(notification.message),
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    color: notification.color ?? Colors.deepOrange,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 100,
                            child: SupportingInfoText(
                              value: notification.message,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(
                                    appNotificationProvider.notifier,
                                  )
                                  .hide();
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
