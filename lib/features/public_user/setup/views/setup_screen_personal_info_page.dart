import 'package:capstone/core/l10n/app_localizations.dart';
import 'dart:io';

import 'package:capstone/core/constants/dropdown_lists.dart';
import 'package:capstone/core/shared/widgets/custom_date_picker_widget.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SetupScreenPersonalInfoPage extends ConsumerStatefulWidget {
  const SetupScreenPersonalInfoPage({super.key});

  @override
  ConsumerState<SetupScreenPersonalInfoPage> createState() => _SetupScreenPersonalInfoPage();
}

class _SetupScreenPersonalInfoPage extends ConsumerState<SetupScreenPersonalInfoPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  TextEditingController houseNumController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController barangayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    firstNameController.text = user.firstName;
    middleNameController.text = user.middleName;
    lastNameController.text = user.lastName;
    birthDateController.text = user.birthDate == 0
        ? ""
        : DateFormat("MM/dd/yy").format(DateTime.fromMillisecondsSinceEpoch(user.birthDate));
    contactNumController = TextEditingController(
      text: user.contactNumber.startsWith("+63") ? user.contactNumber.substring(3) : user.contactNumber,
    );
    houseNumController.text = user.houseNum;
    streetController.text = user.street;
    barangayController.text = user.address;
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
              icon: Icons.person,
              title: l10n.personalInformation.toUpperCase(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FormField<File>(
            initialValue: user.profileImage,
            validator: (value) {
              if (value == null) {
                return l10n.fieldRequired(l10n.profilePhoto);
              }
              return null;
            },
            builder: (field) {
              return Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipOval(
                      child: field.value != null
                          ? Image.file(
                              field.value!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.lighterBlack,
                              child: const Icon(Icons.person, size: 50),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      onPressed: () async {
                        final error = await ref.read(userProvider.notifier).addProfilePicture(ImageSource.camera, l10n);

                        if (error != null && error.isNotEmpty) {
                          if (context.mounted) {
                            CustomSnackbarHelper.show(context, text: error);
                          }
                          return;
                        }

                        if (error == null) {
                          field.didChange(
                            ref.read(userProvider).profileImage,
                          );
                        }
                      },
                      value: l10n.tapToTakePhoto,
                    ),
                  ),
                  if (field.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        field.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
          LabelText(
            value: l10n.requiredNote.toUpperCase(),
            color: Colors.red,
            isBold: false,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomTextField(
                  title: l10n.firstName.toUpperCase(),
                  controller: firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired(l10n.firstName);
                    }

                    return null;
                  },
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setFirstName(value);
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: CustomTextField(
                  title: l10n.middleName.toUpperCase(),
                  controller: middleNameController,
                  validator: (value) {
                    return null;
                  },
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setMiddleName(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            title: l10n.lastName.toUpperCase(),
            controller: lastNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired(l10n.lastName);
              }

              return null;
            },
            onChanged: (value) {
              ref.read(userProvider.notifier).setLastName(value);
            },
            isRequired: true,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomDatePickerWidget(
                  title: l10n.birthDate.toUpperCase(),
                  controller: birthDateController,
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
                      birthDateController.text = formattedDate;
                      ref.read(userProvider.notifier).setBirthDate(date.millisecondsSinceEpoch);
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: CustomDropdownButton(
                  title: l10n.sex.toUpperCase(),
                  value: user.sex.isEmpty ? null : user.sex,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired(l10n.sex);
                    }

                    return null;
                  },
                  items: DropdownLists.sexItems(l10n),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setSex(value!);
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
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
            onChanged: (value) {
              // ref.read(userProvider.notifier).setContactNumber(value);
            },
            isRequired: true,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  title: l10n.houseNumber.toUpperCase(),
                  controller: houseNumController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired(l10n.houseNumber);
                    }

                    return null;
                  },
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setHouseNum(value);
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 3,
                child: CustomTextField(
                  title: l10n.street.toUpperCase(),
                  controller: streetController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired(l10n.street);
                    }

                    return null;
                  },
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setStreet(value);
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: l10n.barangay.toUpperCase(),
            value: user.barangay.isEmpty ? null : user.barangay,
            items: DropdownLists.barangays.map((String barangay) {
              return DropdownMenuItem<String>(
                value: barangay,
                child: BodyText(value: barangay),
              );
            }).toList(),
            onChanged: (value) {
              ref.read(userProvider.notifier).setBarangay(value!);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired(l10n.barangay);
              }
              return null;
            },
            isRequired: true,
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: CustomDropdownButton(
                  title: l10n.nationality.toUpperCase(),
                  value: user.nationality.isEmpty ? null : user.nationality,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired(l10n.nationality);
                    }

                    return null;
                  },
                  items: DropdownLists.nationalityItems(l10n),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setNationality(value!);
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: CustomDropdownButton(
                  title: l10n.civilStatus.toUpperCase(),
                  value: user.civilStatus.isEmpty ? null : user.civilStatus,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.fieldRequired(l10n.civilStatus);
                    }

                    return null;
                  },
                  items: DropdownLists.civilStatusItems(l10n),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setCivilStatus(value!);
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: l10n.religion.toUpperCase(),
            value: user.religion.isEmpty ? null : user.religion,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired(l10n.religion);
              }

              return null;
            },
            items: DropdownLists.religions(l10n),
            onChanged: (value) {
              ref.read(userProvider.notifier).setReligion(value!);
            },
            isRequired: true,
          ),
        ],
      ),
    );
  }
}
