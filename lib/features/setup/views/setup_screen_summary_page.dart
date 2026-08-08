import 'package:capstone/core/shared/widgets/text/form_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_body_small.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupScreenSummaryPage extends ConsumerWidget {
  const SetupScreenSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextTitleSmall(
            title: "PERSONAL PROFILE SUMMARY",
            color: Colors.deepOrange,
          ),
          const SizedBox(
            height: 10,
          ),
          Card(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormBodyMedium(
                          title: "FIRST NAME",
                          body: ref.read(userProvider).firstName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "MIDDLE NAME",
                          body: ref.read(userProvider).middleName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "LAST NAME",
                          body: ref.read(userProvider).lastName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "DATE OF BIRTH",
                          body: DateTime.fromMillisecondsSinceEpoch(
                            ref.read(userProvider).birthDate,
                          ).toString(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "SEX",
                          body: ref.read(userProvider).sex,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "CONTACT NUMBER",
                          body: ref.read(userProvider).contactNumber,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "HOME ADDRESS",
                          body: ref.read(userProvider).address,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "NATIONALITY",
                          body: ref.read(userProvider).nationality,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "CIVIL STATUS",
                          body: ref.read(userProvider).civilStatus,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "RELIGION",
                          body: ref.read(userProvider).religion,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "ID TYPE",
                          body: ref.read(userProvider).idType,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const TextTitleSmall(
            title: "SYSTEM TERMS AND CONDITIONS",
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.lighterDeepOrange,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepOrange, width: 1),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning,
                      color: Colors.red,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const Expanded(
                      child: TextBodySmall(
                        title:
                            "MEAS is a guidance and reporting tool only. It does not replace direct emergency calls to 911 or local hotlines.",
                        color: Colors.red,
                        isBold: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextTitleSmall(
                      title: "DATA PRIVACY",
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text.rich(
                      TextSpan(
                        text: "In compliance with the ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.darkerGrey,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: "Data Privacy Act of 2012 (RA 10173): ",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const TextBodySmall(
                      title: "• All personal data shall be encrypted and stored securely",
                    ),
                    const TextBodySmall(
                      title:
                          "• Your data is only shared with authorized emergency responders and personnel during an active incident",
                    ),
                    const TextBodySmall(
                      title: "• Your location is only transmitted once an emergency report has been triggered",
                    ),
                    const TextBodySmall(
                      title:
                          "• Your data will never be sold or shared with third parties (e.g. non-government agencies, private entities)",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
