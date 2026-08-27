import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/features/public_user/reporting/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupScreenContactNumberPage extends ConsumerStatefulWidget {
  const SetupScreenContactNumberPage({super.key});

  @override
  ConsumerState<SetupScreenContactNumberPage> createState() => _SetupScreenContactNumberPageState();
}

class _SetupScreenContactNumberPageState extends ConsumerState<SetupScreenContactNumberPage> {
  TextEditingController contactNumController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    contactNumController.text = user.contactNumber;
  }

  @override
  void dispose() {
    super.dispose();
    contactNumController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: SectionTitle(
              icon: Icons.contact_phone,
              title: "REGISTER PHONE NUMBER",
            ),
          ),
          const SizedBox(height: 10,),
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
      ],
    );
  }
}
