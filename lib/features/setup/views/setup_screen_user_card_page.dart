import 'package:camera/camera.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/scanner_overlay_painter.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/services/camera_service.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/reporting/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetupScreenUserCardPage extends ConsumerStatefulWidget {
  const SetupScreenUserCardPage({super.key});

  @override
  ConsumerState<SetupScreenUserCardPage> createState() => _SetupScreenUserCardPage();
}

class _SetupScreenUserCardPage extends ConsumerState<SetupScreenUserCardPage> {
  final _cameraServices = CameraService();
  late final CameraController cameraController;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeCamera() async {
    cameraController = await _cameraServices.getCamera();

    if (!mounted) return;

    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    if (isCameraInitialized) {
      cameraController.dispose();
    }
    super.dispose();
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
              icon: Icons.credit_card,
              title: "USER VALIDATION",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: "DOCUMENT ID TYPE",
            value: user.idType.isEmpty ? null : user.idType,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "ID type is required";
              }

              return null;
            },
            hideErrorText: false,
            items: [
              const DropdownMenuItem(
                value: "National ID (PhilSys)",
                child: Text("National ID (PhilSys)"),
              ),
              const DropdownMenuItem(
                value: "Driver's License",
                child: Text("Driver's License"),
              ),
              const DropdownMenuItem(
                value: "Passport",
                child: Text("Passport"),
              ),
            ],
            onChanged: (value) {
              ref.read(userProvider.notifier).setIDType(value!);
            },
            isRequired: true,
          ),
          const SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  // Bottom widget
                  Positioned.fill(
                    child: isCameraInitialized ? CameraPreview(cameraController) : Container(),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ScannerOverlayPainter(),
                      child: Container(),
                    ),
                  ),
                  const Positioned(
                    top: 75,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        Center(
                          child: SupportingInfoText(
                            value: "Align your ID inside the frame",
                            color: AppColors.darkerGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              _initializeCamera();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
            ),
            child: const Text("Start camera"),
          ),
        ],
      ),
    );
  }
}
