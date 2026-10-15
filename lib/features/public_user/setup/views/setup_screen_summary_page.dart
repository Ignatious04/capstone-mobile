import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/info_column.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SetupScreenSummaryPage extends ConsumerWidget {
  const SetupScreenSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            icon: Icons.note,
            title: l10n.personalProfileSummary.toUpperCase(),
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
                          title: l10n.firstName.toUpperCase(),
                          value: ref.read(userProvider).firstName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.middleName.toUpperCase(),
                          value: ref.read(userProvider).middleName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.lastName.toUpperCase(),
                          value: ref.read(userProvider).lastName,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.birthDate.toUpperCase(),
                          value: DateFormat("MMMM dd, yyyy", Localizations.localeOf(context).toString()).format(
                            DateTime.fromMillisecondsSinceEpoch(
                              ref.read(userProvider).birthDate,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.sex.toUpperCase(),
                          value: ref.read(userProvider).sex,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.contactNumber.toUpperCase(),
                          value: ref.read(userProvider).contactNumber,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.homeAddress.toUpperCase(),
                          value:
                              "${ref.read(userProvider).houseNum}, ${ref.read(userProvider).street}, ${ref.read(userProvider).barangay}",
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.nationality.toUpperCase(),
                          value: ref.read(userProvider).nationality,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.civilStatus.toUpperCase(),
                          value: ref.read(userProvider).civilStatus,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.religion.toUpperCase(),
                          value: ref.read(userProvider).religion,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InfoColumn(
                          title: l10n.idType.toUpperCase(),
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
          SectionTitle(
            icon: Icons.rule,
            title: l10n.systemTerms.toUpperCase(),
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
                    Expanded(
                      child: BodyText(
                        value:
                            l10n.meaReminder,
                        color: Colors.red,
                      ),
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
