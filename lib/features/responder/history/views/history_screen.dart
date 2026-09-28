// lib/features/responder/views/responder_history_screen.dart
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:flutter/material.dart';

class ResponderHistoryScreen extends StatelessWidget {
  const ResponderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(
                title: "History",
                body: "Your resolved cases",
              ),
            ),
            const Expanded(
              child: Center(
                child: BodyText(value: "No resolved cases yet"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}