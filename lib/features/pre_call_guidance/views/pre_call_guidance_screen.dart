import 'package:capstone/core/enums/guidance_type_enum.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_body_large.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_medium.dart';
import 'package:capstone/features/pre_call_guidance/providers/guidance_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/pre_call_guidance/views/pre_call_guidance_page_view.dart';
import 'package:capstone/features/reporting/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreCallGuidanceScreen extends ConsumerStatefulWidget {
  const PreCallGuidanceScreen({super.key});

  @override
  ConsumerState<PreCallGuidanceScreen> createState() => _PreCallGuidanceScreenState();
}

class _PreCallGuidanceScreenState extends ConsumerState<PreCallGuidanceScreen> {
  static const size = 25.0;

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
                  const TextTitleMedium(
                    title: "What is your current situation?",
                    color: Colors.black,
                  ),
                  const SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ref.read(reportProvider.notifier).setIncidentType(GuidanceTypeEnum.medical);
                          ref.read(guidanceProvider.notifier).loadQuestions(GuidanceTypeEnum.medical);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PreCallGuidancePageView();
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          iconColor: Colors.green,
                          backgroundColor: AppColors.lighterGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Colors.green,
                            width: 1,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_hospital,
                                size: size,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextBodyLarge(title: "Are you hurt?", color: Colors.green),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(reportProvider.notifier).setIncidentType(GuidanceTypeEnum.police);
                          ref.read(guidanceProvider.notifier).loadQuestions(GuidanceTypeEnum.police);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PreCallGuidancePageView();
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          iconColor: Colors.blue,
                          backgroundColor: AppColors.lighterBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Colors.blue,
                            width: 1,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.local_police,
                                size: size,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextBodyLarge(title: "Is there a violation of the law", color: Colors.blue),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(reportProvider.notifier).setIncidentType(GuidanceTypeEnum.fire);
                          ref.read(guidanceProvider.notifier).loadQuestions(GuidanceTypeEnum.fire);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PreCallGuidancePageView();
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          iconColor: Colors.red,
                          backgroundColor: AppColors.lighterRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.fire_truck,
                                size: size,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextBodyLarge(title: "Is there an ongoing fire?", color: Colors.red),
                            ],
                          ),
                        ),
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
