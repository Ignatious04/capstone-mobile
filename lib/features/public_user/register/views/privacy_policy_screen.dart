import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(value: "Privacy Policy"),
      body: SafeArea(
        child: SingleChildScrollView(),
      ),
    );
  }
}
