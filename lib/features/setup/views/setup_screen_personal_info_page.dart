import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/features/reporting/widgets/section_title.dart';
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
  TextEditingController sexController = TextEditingController();
  TextEditingController contactNumController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final user = ref.read(userProvider);
    firstNameController.text = user.firstName;
    middleNameController.text = user.middleName;
    lastNameController.text = user.lastName;
    birthDateController.text = user.birthDate == 0 ? "" : user.birthDate.toString();
    sexController.text = user.sex;
    contactNumController.text = user.contactNumber;
    addressController.text = user.address;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
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
            CircleAvatar(
              radius: 75.0,
              // backgroundImage: user.profileImage != null
              //     ? FileImage(user.profileImage!)
              //     : null,
              // child: user.profileImage == null
              //     ? Icon(
              //         Icons.person,
              //         size: 75,
              //       )
              //     : null,
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: double.infinity,
              child: CustomElevatedButton(
                onPressed: () async {
                  ref.read(userProvider.notifier).addProfilePicture(ImageSource.gallery);
                },
                value: "Tap to upload photo",
              ),
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
                        style: TextStyle(fontSize: 14),
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
                    items: [
                      const DropdownMenuItem(value: "Male", child: Text("Male")),
                      const DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
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
              title: "CONTACT NUMBER",
              controller: contactNumController,
              keyboardType: TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Contact number is required";
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
            CustomTextField(
              title: "HOME ADDRESS",
              controller: addressController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Home address is required";
                }

                return null;
              },
              onChanged: (value) {
                ref.read(userProvider.notifier).setAddress(value);
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
                        return "Sex is required";
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
                        return "Sex is required";
                      }

                      return null;
                    },
                    items: [
                      const DropdownMenuItem(
                        value: "Single",
                        child: Text("Single"),
                      ),
                      const DropdownMenuItem(
                        value: "Married",
                        child: Text("Married"),
                      ),
                    ],
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
                  return "Sex is required";
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
      ),
    );
  }
}
