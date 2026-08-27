import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderHomeScreen extends ConsumerWidget {
  const ResponderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_hospital, size: 64, color: AppColors.darkerGrey),
              SizedBox(height: 16),
              ScreenTitleText(value: "No active case"),
              SizedBox(height: 8),
              SupportingInfoText(
                value: "You'll be notified here when a case is assigned to you.",
                color: AppColors.darkerGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
