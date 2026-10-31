import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/constants/dropdown_lists.dart';
import 'package:capstone/core/shared/widgets/custom_date_picker_widget.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SetupScreenMedicalInfoPage extends ConsumerStatefulWidget {
  const SetupScreenMedicalInfoPage({super.key});

  @override
  ConsumerState<SetupScreenMedicalInfoPage> createState() => _SetupScreenMedicalInfoPage();
}

class _SetupScreenMedicalInfoPage extends ConsumerState<SetupScreenMedicalInfoPage> {
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController vaccineDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    heightController.text = user.height == 0 ? '' : user.height.toString();
    weightController.text = user.weight == 0 ? '' : user.weight.toString();
    vaccineDateController.text = user.vaccineDate == 0
        ? ""
        : DateFormat("MM/dd/yy").format(DateTime.fromMillisecondsSinceEpoch(user.vaccineDate));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final user = ref.watch(userProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SectionTitle(
              icon: Icons.medical_information,
              title: l10n.medicalInfoOptional.toUpperCase(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          BodyText(
            value: l10n.medicalInfoHelp,
            isBold: false,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: l10n.bloodType.toUpperCase(),
            value: user.bloodType.isEmpty ? null : user.bloodType,
            items: {
              ...DropdownLists.bloodTypes,
              if (user.bloodType.isNotEmpty) user.bloodType, // keeps an old "O" from breaking the dropdown
            }.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
            onChanged: (value) {
              ref.read(userProvider.notifier).setBloodType(value!);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  title: l10n.heightCm.toUpperCase(),
                  controller: heightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setHeight(double.tryParse(value) ?? 0);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextField(
                  title: l10n.weightKg.toUpperCase(),
                  controller: weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setWeight(double.tryParse(value) ?? 0);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: l10n.areYouVaccinated.toUpperCase(),
            value: user.isVaccinated == true ? "Yes" : "No",
            items: [
              DropdownMenuItem(
                value: "Yes",
                child: Text(l10n.yes),
              ),
              DropdownMenuItem(
                value: "No",
                child: Text(l10n.no),
              ),
            ],
            onChanged: (value) {
              if (value == "Yes") {
                ref.read(userProvider.notifier).setIsVaccinated(true);
              } else {
                ref.read(userProvider.notifier).setIsVaccinated(false);
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: CustomDropdownButton(
                  title: l10n.vaccineType.toUpperCase(),
                  value: user.vaccineType.isEmpty ? null : user.vaccineType,
                  items: DropdownLists.vaccineItems(l10n),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setVaccineType(value!);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomDatePickerWidget(
                  title: l10n.vaccineDate.toUpperCase(),
                  controller: vaccineDateController,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );

                    if (date != null) {
                      final formattedDate = DateFormat(
                        "MM/dd/yy",
                      ).format(date);
                      vaccineDateController.text = formattedDate;
                      ref.read(userProvider.notifier).setVaccineDate(date.millisecondsSinceEpoch);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
