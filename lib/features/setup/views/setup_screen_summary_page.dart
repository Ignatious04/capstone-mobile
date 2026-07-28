import 'package:capstone/core/shared/widgets/text/form_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
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
          Card(
            color: AppColors.lighterBlack,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PERSONAL PROFILE SUMMARY",
                      style:
                          Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormBodyMedium(
                          title: "FIRST NAME",
                          body: ref.read(userProvider).firstName,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "MIDDLE NAME",
                          body: ref.read(userProvider).middleName,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "LAST NAME",
                          body: ref.read(userProvider).lastName,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "DATE OF BIRTH",
                          body: DateTime.fromMillisecondsSinceEpoch(
                            ref.read(userProvider).birthDate,
                          ).toString(),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "SEX",
                          body: ref.read(userProvider).sex,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "CONTACT NUMBER",
                          body: ref.read(userProvider).contactNumber,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "HOME ADDRESS",
                          body: ref.read(userProvider).address,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "NATIONALITY",
                          body: ref.read(userProvider).nationality,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "CIVIL STATUS",
                          body: ref.read(userProvider).civilStatus,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FormBodyMedium(
                          title: "RELIGION",
                          body: ref.read(userProvider).religion,
                        ),
                        SizedBox(
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
          SizedBox(height: 10),
          Text(
            "SYSTEM TERMS AND CONDITIONS",
            style:
                Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 10),
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
                    Icon(
                      Icons.warning,
                      color: Colors.deepOrange,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        "MEAS is a guidance and reporting tool only. It does not replace direct emergency calls to 911 or local hotlines.",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Card(
            color: AppColors.lighterBlack,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DATA PRIVACY",
                      style:
                          Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text.rich(
                      TextSpan(
                        text: "In compliance with the ",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
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
                    SizedBox(
                      height: 10,
                    ),
                    TextBodySmall(
                      title: "• All personal data shall be encrypted and stored securely",
                    ),
                    TextBodySmall(
                      title:
                          "• Your data is only shared with authorized emergency responders and personnel during an active incident",
                    ),
                    TextBodySmall(
                      title: "• Your location is only transmitted once an emergency report has been triggered",
                    ),
                    TextBodySmall(
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
