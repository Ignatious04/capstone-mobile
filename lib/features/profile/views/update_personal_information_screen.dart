import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
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
    contactNumController = TextEditingController(text: widget.user.contactNumber);
    addressController = TextEditingController(text: widget.user.address);

    sex = widget.user.sex;
    nationality = widget.user.nationality;
    civilStatus = widget.user.civilStatus;
    religion = widget.user.religion;
  }

  @override
  void dispose() {
    contactNumController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("User ID: ${widget.user.userID}");
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: TextTitleSmall(
          title: "Back",
          color: Colors.white,
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(
                title: "Update Information",
              ),
            ),
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
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
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
                        items: [
                          DropdownMenuItem(
                            value: "Filipino",
                            child: Text("Filipino"),
                          ),
                        ],
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
                        items: [
                          DropdownMenuItem(
                            value: "Single",
                            child: Text("Single"),
                          ),
                          DropdownMenuItem(
                            value: "Married",
                            child: Text("Married"),
                          ),
                        ],
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
                        items: [
                          DropdownMenuItem(
                            value: "Catholic",
                            child: Text("Catholic"),
                          ),
                          DropdownMenuItem(
                            value: "Iglesia ni Cristo",
                            child: Text("Iglesia ni Cristo"),
                          ),
                        ],
                        onChanged: (value) {
                          religion = value!;
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref.read(userRepositoryProvider).updateUser(
                              widget.user.userID,
                              {
                                "sex": sex,
                                "contactNumber": contactNumController.text,
                                "address": addressController.text,
                                "nationality": nationality,
                                "civilStatus": civilStatus,
                                "religion": religion,
                              },
                            );

                            if (!context.mounted) {
                              return;
                            }

                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Confirm"),
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
