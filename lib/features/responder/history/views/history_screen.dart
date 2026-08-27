// lib/features/responder/views/responder_history_screen.dart
import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:flutter/material.dart';

class ResponderHistoryScreen extends StatelessWidget {
  const ResponderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: const Text("History", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: ScreenTitleText(value: "No resolved cases yet"),
      ),
    );
  }
}
