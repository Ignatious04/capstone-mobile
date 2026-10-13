import 'package:capstone/core/constants/dropdown_lists.dart';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
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
  late final TextEditingController birthDateController;
  late final TextEditingController sexController;
  late final TextEditingController contactNumController;
  late final TextEditingController addressController;

  late String sex;
  late String nationality;
  late String civilStatus;
  late String religion;

  @override
  void initState() {
    super.initState();

    birthDateController = TextEditingController(
      text: DateFormat("MMMM dd, yyyy").format(
        DateTime.fromMillisecondsSinceEpoch(
          widget.user.birthDate,
        ),
      ),
    );
    sexController = TextEditingController(text: widget.user.sex);
    contactNumController = TextEditingController(
      text: widget.user.contactNumber.startsWith("+63")
          ? widget.user.contactNumber.substring(3)
          : widget.user.contactNumber,
    );
    addressController = TextEditingController(text: widget.user.address);

    sex = widget.user.sex;
    nationality = widget.user.nationality;
    civilStatus = widget.user.civilStatus;
    religion = widget.user.religion;
  }

  @override
  void dispose() {
    birthDateController.dispose();
    sexController.dispose();
    contactNumController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("User ID: ${widget.user.userID}");
    return Scaffold(
      appBar: CustomAppBar(value: "Update Information"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        title: "DATE OF BIRTH",
                        controller: birthDateController,
                        isReadOnly: true,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: "SEX",
                        controller: sexController,
                        isReadOnly: true,
                        color: Colors.black54,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: "CONTACT NO.",
                        prefixText: "+63 ",
                        controller: contactNumController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: false), // added
                        inputFormatters: [
                          // added
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Contact no. is required";
                          }
                          if (value.length != 10) {
                            // added
                            return "Enter a valid 10-digit number";
                          }

                          return null;
                        },
                        onChanged: (value) {},
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      CustomTextField(
                        title: "HOME ADDRESS",
                        controller: addressController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Home address is required";
                          }

                          return null;
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      CustomDropdownButton(
                        title: "NATIONALITY",
                        value: nationality,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nationality is required";
                          }

                          return null;
                        },
                        items: DropdownLists.nationalityItems,
                        onChanged: (value) {
                          setState(() {
                            nationality = value!;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      CustomDropdownButton(
                        title: "CIVIL STATUS",
                        value: civilStatus,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Civil status is required";
                          }

                          return null;
                        },
                        items: DropdownLists.sexItems,
                        onChanged: (value) {
                          setState(() {
                            civilStatus = value!;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      CustomDropdownButton(
                        title: "RELIGION",
                        value: religion,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Religion is required";
                          }

                          return null;
                        },
                        items: DropdownLists.religions,
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
                          onPressed: () async {
                            final confirmed = await showConfirmationDialog(
                              context,
                              title: "Confirmation",
                              content: "Do you wish to update your personal information?",
                            );

                            if (confirmed != true) {
                              return;
                            }

                            final localNumber = contactNumController.text;
                            final e164Number = "+63$localNumber";

                            final numberChanged = e164Number != widget.user.contactNumber;

                            if (numberChanged) {
                              if (!context.mounted) {
                                return;
                              }

                              final confirmNumberChange = await showConfirmationDialog(
                                context,
                                title: "Note:",
                                content: "You will have to re-verify your number, confirm?",
                              );

                              if (confirmNumberChange != true) {
                                return;
                              }
                            }

                            await ref.read(userRepositoryProvider).updateUser(
                              widget.user.userID,
                              {
                                "sex": sex,
                                "contactNumber": e164Number,
                                "address": addressController.text,
                                "nationality": nationality,
                                "civilStatus": civilStatus,
                                "religion": religion,
                                if (numberChanged) "isContactNumberVerified": false,
                              },
                            );

                            if (!context.mounted) {
                              return;
                            }

                            Navigator.pop(context);
                          },
                          value: "Confirm",
                        ),
                      ),
                    ],
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
