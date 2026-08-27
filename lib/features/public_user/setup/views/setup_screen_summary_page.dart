import 'package:capstone/core/shared/widgets/info_column.dart';
import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/paragraph_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/reporting/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SetupScreenSummaryPage extends ConsumerWidget {
  const SetupScreenSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            icon: Icons.note,
            title: "PERSONAL PROFILE SUMMARY",
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
                        InfoColumn(
                          title: "FIRST NAME",
                          value: ref.read(userProvider).firstName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "MIDDLE NAME",
                          value: ref.read(userProvider).middleName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "LAST NAME",
                          value: ref.read(userProvider).lastName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "DATE OF BIRTH",
                          value: DateFormat("MMMM dd, yyyy").format(
                            DateTime.fromMillisecondsSinceEpoch(
                              ref.read(userProvider).birthDate,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "SEX",
                          value: ref.read(userProvider).sex,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "CONTACT NUMBER",
                          value: ref.read(userProvider).contactNumber,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "HOME ADDRESS",
                          value: ref.read(userProvider).address,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "NATIONALITY",
                          value: ref.read(userProvider).nationality,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "CIVIL STATUS",
                          value: ref.read(userProvider).civilStatus,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "RELIGION",
                          value: ref.read(userProvider).religion,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: "ID TYPE",
                          value: ref.read(userProvider).idType,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SectionTitle(
            icon: Icons.rule,
            title: "SYSTEM TERMS AND CONDITIONS",
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
                      child: ParagraphText(
                        value:
                            "MEAS is a guidance and reporting tool only. It does not replace direct emergency calls to 911 or local hotlines.",
                        color: Colors.red,
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
                    const CardTitleText(
                      value: "DATA PRIVACY",
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text.rich(
                      TextSpan(
                        text: "In compliance with the ",
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          TextSpan(
                            text: "Data Privacy Act of 2012 (RA 10173): ",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const ParagraphText(
                      value: "• All personal data shall be encrypted and stored securely",
                    ),
                    const ParagraphText(
                      value:
                          "• Your data is only shared with authorized emergency responders and personnel during an active incident",
                    ),
                    const ParagraphText(
                      value: "• Your location is only transmitted once an emergency report has been triggered",
                    ),
                    const ParagraphText(
                      value:
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
