import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/service_button.dart';
import 'package:capstone/features/public_user/guides/widgets/guides_entry_card.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/pre_call_guidance/utilities/offline_report_helper.dart';
import 'package:capstone/features/public_user/pre_call_guidance/views/pre_call_guidance_page_view.dart';
import 'package:capstone/core/shared/providers/report_provider.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidanceScreen extends ConsumerStatefulWidget {
  const PreCallGuidanceScreen({super.key});

  @override
  ConsumerState<PreCallGuidanceScreen> createState() => _PreCallGuidanceScreenState();
}

class _PreCallGuidanceScreenState extends ConsumerState<PreCallGuidanceScreen> {
  Future<bool> _canStart() async {
    final isOnline = !await isDeviceOffline();
    if (!mounted) return false;
    // Offline reports go out by SMS, which is also verified-only. Check it now
    // instead of letting NotVerifiedException surface after all the questions.
    return isOnline ? await ensureCanReport(context, ref) : await ensureVerified(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: CustomHeaderWidget(
                  title: l10n.preCallGuidance,
                  body: l10n.guidanceSubtitle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    SectionTitle(
                      icon: Icons.question_answer,
                      title: l10n.currentSituation,
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ServiceButton(
                          onPressed: () async {
                            if (!await _canStart()) return;
                            ref.read(reportProvider.notifier).setIncidentType(ServiceTypeEnum.medical);
                            ref.read(guidanceProvider.notifier).loadQuestions(ServiceTypeEnum.medical);

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PreCallGuidancePageView();
                                },
                              ),
                            );
                          },
                          value: l10n.areYouHurt,
                          icon: Icons.medical_services,
                          color: Colors.green,
                          backgroundColor: AppColors.lighterGreen,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ServiceButton(
                          onPressed: () async {
                            if (!await _canStart()) return;
                            ref.read(reportProvider.notifier).setIncidentType(ServiceTypeEnum.police);
                            ref.read(guidanceProvider.notifier).loadQuestions(ServiceTypeEnum.police);

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PreCallGuidancePageView();
                                },
                              ),
                            );
                          },
                          value: l10n.lawViolation,
                          icon: Icons.local_police,
                          color: Colors.blue,
                          backgroundColor: AppColors.lighterBlue,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ServiceButton(
                          onPressed: () async {
                            if (!await _canStart()) return;
                            ref.read(reportProvider.notifier).setIncidentType(ServiceTypeEnum.fire);
                            ref.read(guidanceProvider.notifier).loadQuestions(ServiceTypeEnum.fire);

                            if (!context.mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PreCallGuidancePageView();
                                },
                              ),
                            );
                          },
                          value: l10n.ongoingFire,
                          icon: Icons.fire_truck,
                          color: Colors.red,
                          backgroundColor: AppColors.lighterRed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const GuidesEntryCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
