import 'dart:io';

import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/reporting/widgets/section_title.dart';
import 'package:flutter/material.dart';
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

  static const _sexItems = [
    DropdownMenuItem(
      value: "Male",
      child: DataValueText(value: "Male"),
    ),
    DropdownMenuItem(
      value: "Female",
      child: DataValueText(value: "Female"),
    ),
  ];

  static const _civilStatusItems = [
    DropdownMenuItem(
      value: "Single",
      child: DataValueText(value: "Single"),
    ),
    DropdownMenuItem(
      value: "Married",
      child: DataValueText(value: "Married"),
    ),
  ];

  final List<String> _barangays = const [
    'Agapito del Rosario',
    'Amsic',
    'Anunas',
    'Balibago',
    'Capaya',
    'Claro M. Recto',
    'Cuayan',
    'Cutud',
    'Lourdes North West',
    'Lourdes Sur (Talimundoc)',
    'Lourdes Sur East',
    'Malabañas (Malabanias)',
    'Margot',
    'Mining',
    'Marisol (Ninoy Aquino)',
    'Pampang (Santo Niño)',
    'Pandan',
    'Pulung Bulu (Pulungbulu)',
    'Pulung Cacutud',
    'Pulung Maragul',
    'Salapungan',
    'San José',
    'San Nicolas',
    'Santa Teresita',
    'Santa Trinidad',
    'Santo Cristo',
    'Santo Domingo',
    'Santo Rosario',
    'Sapalibutad',
    'Sapangbato',
    'Tabun',
    'Virgen Delos Remedios',
  ];

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
    contactNumController.text = user.contactNumber;
    houseNumController.text = user.houseNum;
    streetController.text = user.street;
    barangayController.text = user.address;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: SectionTitle(
              icon: Icons.person,
              title: "PERSONAL INFORMATION",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          FormField<File>(
            initialValue: user.profileImage,
            validator: (value) {
              if (value == null) {
                return "Profile photo is required";
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
                        final error = await ref.read(userProvider.notifier).addProfilePicture(ImageSource.camera);

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
                      value: "Tap to take photo",
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
          const SupportingInfoText(
            value: "NOTE: REQUIRED FIELDS ARE DENOTED BY AN ASTERISK (*)",
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
                  title: "FIRST NAME",
                  controller: firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "First name is required";
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
                  title: "MIDDLE NAME",
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
            title: "LAST NAME",
            controller: lastNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Last name is required";
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataLabelText(value: "DATE OF BIRTH"),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: birthDateController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Birth date is required";
                        }

                        return null;
                      },
                      readOnly: true,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                          ),
                      decoration: InputDecoration(
                        errorStyle: TextStyle(fontSize: 0),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
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
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                flex: 2,
                child: CustomDropdownButton(
                  title: "SEX",
                  value: user.sex.isEmpty ? null : user.sex,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Sex is required";
                    }

                    return null;
                  },
                  items: _sexItems,
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
            title: "CONTACT NO.",
            controller: contactNumController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Contact no. is required";
              }

              return null;
            },
            onChanged: (value) {
              ref.read(userProvider.notifier).setContactNumber(value);
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
                  title: "HOUSE NO.",
                  controller: houseNumController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "House no. is required";
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
                  title: "STREET",
                  controller: streetController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Street is required";
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
            title: "BARANGAY",
            value: user.barangay.isEmpty ? null : user.barangay,
            items: _barangays.map((String barangay) {
              return DropdownMenuItem<String>(
                value: barangay,
                child: DataValueText(value: barangay),
              );
            }).toList(),
            onChanged: (value) {
              ref.read(userProvider.notifier).setBarangay(value!);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Barangay is required";
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
                  title: "NATIONALITY",
                  value: user.nationality.isEmpty ? null : user.nationality,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Nationality is required";
                    }

                    return null;
                  },
                  items: [
                    const DropdownMenuItem(
                      value: "Filipino",
                      child: Text("Filipino"),
                    ),
                  ],
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
                  title: "CIVIL STATUS",
                  value: user.civilStatus.isEmpty ? null : user.civilStatus,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Civil status is required";
                    }

                    return null;
                  },
                  items: _civilStatusItems,
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
            title: "RELIGION",
            value: user.religion.isEmpty ? null : user.religion,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Religion is required";
              }

              return null;
            },
            items: [
              const DropdownMenuItem(
                value: "Catholic",
                child: Text("Catholic"),
              ),
              const DropdownMenuItem(
                value: "Iglesia ni Cristo",
                child: Text("Iglesia ni Cristo"),
              ),
            ],
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
