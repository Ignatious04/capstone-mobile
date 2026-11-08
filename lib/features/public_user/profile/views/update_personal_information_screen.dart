import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/constants/dropdown_lists.dart';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class UpdatePersonalInformationScreen extends ConsumerStatefulWidget {
  const UpdatePersonalInformationScreen({super.key, required this.user});

  final UserModel user;

  @override
  ConsumerState<UpdatePersonalInformationScreen> createState() => _UpdatePersonalInformationScreenState();
}

class _UpdatePersonalInformationScreenState extends ConsumerState<UpdatePersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController firstNameController;
  late final TextEditingController middleNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController birthDateController;
  late final TextEditingController sexController;
  late final TextEditingController contactNumController;
  late final TextEditingController houseNumController;
  late final TextEditingController streetController;

  String? barangay;
  late String nationality;
  late String civilStatus;
  late String religion;

  @override
  void initState() {
    super.initState();

    final user = widget.user;

    // Older docs only stored the combined address ("house, street, barangay").
    // Same fallback as UserNotifier.prefillForResubmission.
    var houseNum = user.houseNum;
    var street = user.street;
    var brgy = user.barangay;
    if (houseNum.isEmpty && street.isEmpty && brgy.isEmpty && user.address.isNotEmpty) {
      final parts = user.address.split(', ');
      if (parts.length >= 3) {
        houseNum = parts.first;
        street = parts.sublist(1, parts.length - 1).join(', ');
        brgy = parts.last;
      }
    }

    firstNameController = TextEditingController(text: user.firstName);
    middleNameController = TextEditingController(text: user.middleName);
    lastNameController = TextEditingController(text: user.lastName);
    birthDateController = TextEditingController(
      text: DateFormat("MMMM dd, yyyy").format(
        DateTime.fromMillisecondsSinceEpoch(
          user.birthDate,
        ),
      ),
    );
    sexController = TextEditingController(text: user.sex);
    contactNumController = TextEditingController(
      text: user.contactNumber.startsWith("+63") ? user.contactNumber.substring(3) : user.contactNumber,
    );
    houseNumController = TextEditingController(text: houseNum);
    streetController = TextEditingController(text: street);

    // The dropdown asserts if its value isn't one of the items.
    barangay = DropdownLists.barangays.contains(brgy) ? brgy : null;
    nationality = user.nationality;
    civilStatus = user.civilStatus;
    religion = user.religion;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    birthDateController.dispose();
    sexController.dispose();
    contactNumController.dispose();
    houseNumController.dispose();
    streetController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    // Without a Form around the fields, none of the validators ever ran.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showConfirmationDialog(
      context,
      title: l10n.confirmation,
      content: l10n.updateInfoPrompt,
    );

    if (confirmed != true) {
      return;
    }

    final e164Number = "+63${contactNumController.text}";
    final numberChanged = e164Number != widget.user.contactNumber;

    if (numberChanged) {
      if (!mounted) {
        return;
      }

      final confirmNumberChange = await showConfirmationDialog(
        context,
        title: l10n.noteLabel,
        content: l10n.reverifyNote,
      );

      if (confirmNumberChange != true) {
        return;
      }
    }

    final houseNum = houseNumController.text.trim();
    final street = streetController.text.trim();

    await ref.read(userRepositoryProvider).updateUser(
      widget.user.userID,
      {
        "contactNumber": e164Number,
        // Same fields and same combined format the setup flow writes.
        "houseNum": houseNum,
        "street": street,
        "barangay": barangay,
        "address": "$houseNum, $street, $barangay",
        "nationality": nationality,
        "civilStatus": civilStatus,
        "religion": religion,
        "updatedAt": DateTime.now().millisecondsSinceEpoch,
        if (numberChanged) "isContactNumberVerified": false,
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.updateInformation),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          icon: Icons.person,
                          title: l10n.personalInformation.toUpperCase(),
                        ),
                        const SizedBox(height: 10),
                        LabelText(
                          value: l10n.requiredNote.toUpperCase(),
                          color: Colors.red,
                          isBold: false,
                        ),
                        const SizedBox(height: 10),
                        // Name, birth date and sex were checked against the ID,
                        // so they're shown the way setup shows them but stay read-only.
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomTextField(
                                title: l10n.firstName.toUpperCase(),
                                controller: firstNameController,
                                isReadOnly: true,
                                color: AppColors.blackTextMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                title: l10n.middleName.toUpperCase(),
                                controller: middleNameController,
                                isReadOnly: true,
                                color: AppColors.blackTextMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          title: l10n.lastName.toUpperCase(),
                          controller: lastNameController,
                          isReadOnly: true,
                          color: AppColors.blackTextMuted,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomTextField(
                                title: l10n.birthDate.toUpperCase(),
                                controller: birthDateController,
                                isReadOnly: true,
                                color: AppColors.blackTextMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: CustomTextField(
                                title: l10n.sex.toUpperCase(),
                                controller: sexController,
                                isReadOnly: true,
                                color: AppColors.blackTextMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          title: l10n.contactNumber.toUpperCase(),
                          prefixText: "+63 ",
                          controller: contactNumController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: false),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.fieldRequired(l10n.contactNumber);
                            }
                            if (value.length != 10) {
                              return l10n.invalidPhone10;
                            }

                            return null;
                          },
                          hideErrorText: false,
                          isRequired: true,
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 10),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.directions,
                              size: 25,
                              color: AppColors.blackTextMuted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: LabelText(
                                value: l10n.homeAddressHelper.toUpperCase(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                title: l10n.houseNumber.toUpperCase(),
                                controller: houseNumController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                title: l10n.street.toUpperCase(),
                                controller: streetController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.fieldRequired(l10n.street);
                                  }

                                  return null;
                                },
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomDropdownButton(
                          title: l10n.barangay.toUpperCase(),
                          value: barangay,
                          items: DropdownLists.barangays.map((String name) {
                            return DropdownMenuItem<String>(
                              value: name,
                              child: BodyText(value: name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              barangay = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.fieldRequired(l10n.barangay);
                            }
                            return null;
                          },
                          isRequired: true,
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 10),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CustomDropdownButton(
                                title: l10n.nationality.toUpperCase(),
                                value: nationality,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.fieldRequired(l10n.nationality);
                                  }

                                  return null;
                                },
                                items: DropdownLists.nationalityItems(l10n),
                                onChanged: (value) {
                                  setState(() {
                                    nationality = value!;
                                  });
                                },
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: CustomDropdownButton(
                                title: l10n.civilStatus.toUpperCase(),
                                value: civilStatus,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return l10n.fieldRequired(l10n.civilStatus);
                                  }

                                  return null;
                                },
                                items: DropdownLists.civilStatusItems(l10n),
                                onChanged: (value) {
                                  setState(() {
                                    civilStatus = value!;
                                  });
                                },
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        CustomDropdownButton(
                          title: l10n.religion.toUpperCase(),
                          value: religion,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.fieldRequired(l10n.religion);
                            }

                            return null;
                          },
                          items: DropdownLists.religions(l10n),
                          onChanged: (value) {
                            setState(() {
                              religion = value!;
                            });
                          },
                          isRequired: true,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: CustomElevatedButton(
                            onPressed: () => _submit(l10n),
                            value: l10n.confirm,
                            color: AppColors.whiteTextFull,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
