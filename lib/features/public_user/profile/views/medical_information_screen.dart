import 'package:capstone/core/constants/dropdown_lists.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_date_picker_widget.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MedicalInformationScreen extends ConsumerStatefulWidget {
  const MedicalInformationScreen({super.key, required this.user});
  final UserModel user;

  @override
  ConsumerState<MedicalInformationScreen> createState() => _MedicalInformationScreenState();
}

class _MedicalInformationScreenState extends ConsumerState<MedicalInformationScreen> {
  static const _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  late final TextEditingController heightController;
  late final TextEditingController weightController;
  late final TextEditingController vaccineDateController;
  late String bloodType;
  late bool isVaccinated;
  late String vaccineType;
  late int vaccineDate;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    bloodType = u.bloodType;
    isVaccinated = u.isVaccinated;
    vaccineType = u.vaccineType;
    vaccineDate = u.vaccineDate;
    heightController = TextEditingController(text: u.height == 0 ? '' : u.height.toString());
    weightController = TextEditingController(text: u.weight == 0 ? '' : u.weight.toString());
    vaccineDateController = TextEditingController(
      text: vaccineDate == 0
          ? ''
          : DateFormat("MM/dd/yy").format(DateTime.fromMillisecondsSinceEpoch(vaccineDate)),
    );
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    vaccineDateController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    setState(() => saving = true);
    try {
      await ref.read(userRepositoryProvider).updateUser(widget.user.userID, {
        'bloodType': bloodType,
        'height': double.tryParse(heightController.text) ?? 0,
        'weight': double.tryParse(weightController.text) ?? 0,
        'isVaccinated': isVaccinated,
        'vaccineType': isVaccinated ? vaccineType : '',
        'vaccineDate': isVaccinated ? vaccineDate : 0,
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      CustomSnackbarHelper.show(context, text: l10n.somethingWentWrong);
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Keep an old value (e.g. the setup page's "O") from breaking the dropdown.
    final bloodItems = {..._bloodTypes, if (bloodType.isNotEmpty) bloodType};

    return Scaffold(
      appBar: CustomAppBar(value: l10n.medicalInformation),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BodyText(value: l10n.medicalInfoHelp, isBold: false),
                    const SizedBox(height: 10),
                    CustomDropdownButton(
                      title: l10n.bloodType.toUpperCase(),
                      value: bloodType.isEmpty ? null : bloodType,
                      items: bloodItems.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => setState(() => bloodType = v ?? ''),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                        child: CustomTextField(
                          title: l10n.heightCm.toUpperCase(),
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomTextField(
                          title: l10n.weightKg.toUpperCase(),
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),
                    CustomDropdownButton(
                      title: l10n.areYouVaccinated.toUpperCase(),
                      value: isVaccinated ? 'Yes' : 'No',
                      items: [
                        DropdownMenuItem(value: 'Yes', child: Text(l10n.yes)),
                        DropdownMenuItem(value: 'No', child: Text(l10n.no)),
                      ],
                      onChanged: (v) => setState(() => isVaccinated = v == 'Yes'),
                    ),
                    if (isVaccinated) ...[
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: CustomDropdownButton(
                            title: l10n.vaccineType.toUpperCase(),
                            value: vaccineType.isEmpty ? null : vaccineType,
                            items: DropdownLists.vaccineItems(l10n),
                            onChanged: (v) => setState(() => vaccineType = v ?? ''),
                          ),
                        ),
                        const SizedBox(width: 10),
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
                                vaccineDateController.text = DateFormat("MM/dd/yy").format(date);
                                setState(() => vaccineDate = date.millisecondsSinceEpoch);
                              }
                            },
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: saving ? null : () => _save(l10n),
                  value: l10n.save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}