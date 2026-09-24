import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/service_button.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/pre_call_guidance/views/pre_call_guidance_page_view.dart';
import 'package:capstone/features/public_user/reporting/providers/report_provider.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidanceScreen extends ConsumerStatefulWidget {
  const PreCallGuidanceScreen({super.key});

  @override
  ConsumerState<PreCallGuidanceScreen> createState() => _PreCallGuidanceScreenState();
}

class _PreCallGuidanceScreenState extends ConsumerState<PreCallGuidanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(
                title: "Pre-Call Guidance",
                body: "Let us route you to the right service",
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 75,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SectionTitle(
                    icon: Icons.question_answer,
                    title: "What is your current situation?",
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ServiceButton(
                        onPressed: () {
                          ref.read(reportProvider.notifier).setIncidentType(ServiceTypeEnum.medical);
                          ref.read(guidanceProvider.notifier).loadQuestions(ServiceTypeEnum.medical);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PreCallGuidancePageView();
                              },
                            ),
                          );
                        },
                        value: "Are you hurt?",
                        icon: Icons.medical_services,
                        color: Colors.green,
                        backgroundColor: AppColors.lighterGreen,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ServiceButton(
                        onPressed: () {
                          ref.read(reportProvider.notifier).setIncidentType(ServiceTypeEnum.police);
                          ref.read(guidanceProvider.notifier).loadQuestions(ServiceTypeEnum.police);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PreCallGuidancePageView();
                              },
                            ),
                          );
                        },
                        value: "Is there a violation of the law?",
                        icon: Icons.local_police,
                        color: Colors.blue,
                        backgroundColor: AppColors.lighterBlue,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ServiceButton(
                        onPressed: () {
                          ref.read(reportProvider.notifier).setIncidentType(ServiceTypeEnum.fire);
                          ref.read(guidanceProvider.notifier).loadQuestions(ServiceTypeEnum.fire);
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PreCallGuidancePageView();
                              },
                            ),
                          );
                        },
                        value: "Is there an ongoing fire?",
                        icon: Icons.fire_truck,
                        color: Colors.red,
                        backgroundColor: AppColors.lighterRed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
