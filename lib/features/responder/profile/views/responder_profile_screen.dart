// lib/features/responder/views/responder_profile_screen.dart
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/models/responder_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/info_column.dart';
import 'package:capstone/core/shared/widgets/language_selector.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:capstone/features/responder/active_case/providers/responder_location_sharing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderProfileScreen extends ConsumerWidget {
  const ResponderProfileScreen({super.key});

  IconData _getDepartmentIcon(ServiceTypeEnum type) {
    switch (type) {
      case ServiceTypeEnum.fire:
        return Icons.local_fire_department_outlined;
      case ServiceTypeEnum.police:
        return Icons.local_police_outlined;
      case ServiceTypeEnum.medical:
        return Icons.local_hospital_outlined;
    }
  }

  Color _getDepartmentColor(ServiceTypeEnum type) {
    switch (type) {
      case ServiceTypeEnum.fire:
        return Colors.red;
      case ServiceTypeEnum.police:
        return Colors.blue;
      case ServiceTypeEnum.medical:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responderAsync = ref.watch(currentAuthenticatedResponderProvider);

    return Scaffold(
      body: SafeArea(
        child: responderAsync.when(
          data: (responder) {
            if (responder == null) {
              return const Center(child: CustomCircularProgressIndicator());
            }
            return _ResponderProfileBody(
              responder: responder,
              departmentIcon: _getDepartmentIcon(responder.department),
              departmentColor: _getDepartmentColor(responder.department),
            );
          },
          error: (error, _) => Center(child: Text(error.toString())),
          loading: () => const Center(child: CustomCircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _ResponderProfileBody extends ConsumerWidget {
  const _ResponderProfileBody({
    required this.responder,
    required this.departmentIcon,
    required this.departmentColor,
  });

  final ResponderModel responder;
  final IconData departmentIcon;
  final Color departmentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomHeaderWidget(title: l10n.responderProfile, body: l10n.viewYourAccount),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: departmentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(departmentIcon, size: 50, color: departmentColor),
                ),
                const SizedBox(height: 10),
                HeadlineText(value: responder.fullName),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoColumn(title: l10n.responderCode.toUpperCase(), value: responder.responderCode),
                      const SizedBox(height: 10),
                      InfoColumn(title: l10n.role.toUpperCase(), value: responder.role.toUpperCase()),
                      const SizedBox(height: 10),
                      InfoColumn(title: l10n.department.toUpperCase(), value: responder.department.label(l10n)),
                      const SizedBox(height: 10),
                      InfoColumn(title: l10n.email.toUpperCase(), value: responder.email),
                      const SizedBox(height: 10),
                      InfoColumn(title: l10n.contactNumber.toUpperCase(), value: responder.contactNumber),
                      const SizedBox(height: 10),
                      Divider(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.language, size: 25),
                    const SizedBox(width: 10),
                    BodyText(value: l10n.language),
                    const Spacer(),
                    const LanguageSelector(),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPressed: () async {
                      final confirmed = await showConfirmationDialog(
                        context,
                        title: l10n.attention,
                        content: l10n.logoutConfirm,
                      );
                      if (confirmed != true) return;
                      await ref.read(responderLocationSharingProvider).stopSharing();
                      final uid = ref.read(firebaseAuthProvider).currentUser?.uid;
                      if (uid != null) {
                        await ref.read(pushNotificationServiceProvider).clearToken(uid);
                      }
                      await ref.read(firebaseAuthRepositoryProvider).signOut();
                    },
                    icon: const Icon(Icons.logout, size: 25),
                    color: Colors.red,
                    backgroundColor: Colors.white,
                    value: l10n.logout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
