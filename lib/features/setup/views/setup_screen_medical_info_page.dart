import 'package:capstone/core/shared/widgets/custom_date_picker_widget.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: TextTitleSmall(
              title: "MEDICAL INFORMATION (OPTIONAL)",
              color: Colors.black,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const TextBodySmall(
            title: "This information helps emergency responders provide better care. All fields are optional.",
            isBold: false,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: "BLOOD TYPE",
            value: user.bloodType.isEmpty ? null : user.bloodType,
            items: [
              const DropdownMenuItem(
                value: "O",
                child: Text("O"),
              ),
            ],
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
                  title: "HEIGHT (CM)",
                  controller: heightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setHeight(double.tryParse(value)!);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: CustomTextField(
                  title: "WEIGHT (KG)",
                  controller: weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setWeight(double.tryParse(value)!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: "ARE YOU VACINNATED?",
            value: user.isVaccinated == true ? "Yes" : "No",
            items: [
              const DropdownMenuItem(
                value: "Yes",
                child: Text("Yes"),
              ),
              const DropdownMenuItem(
                value: "No",
                child: Text("No"),
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
                  title: "VACCINE TYPE",
                  value: user.vaccineType.isEmpty ? null : user.vaccineType,
                  items: [
                    DropdownMenuItem(
                      value: "Anti-Rabies",
                      child: Text("Anti-Rabies"),
                    ),
                  ],
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
                  title: "VACCINE DATE",
                  controller: vaccineDateController,
                  onChanged: (value) {
                    ref.read(userProvider.notifier).setVaccineDate(value);
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
