import 'package:capstone/core/l10n/app_localizations.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/scanner_overlay_painter.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/services/camera_service.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
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
  bool isProcessing = false;
  String? idCheckError;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameraController = await _cameraServices.getCamera();

    if (!mounted) return;

    setState(() {
      isCameraInitialized = true;
    });
  }

  Future<File> takePicture() async {
    final image = await cameraController.takePicture();
    final file = File(image.path);
    return file;
  }

  Future<String?> getIDFromCard(File file) async {
    final error = await ref.read(userProvider.notifier).captureId(file, AppLocalizations.of(context)!);
    return error;
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
    final l10n = AppLocalizations.of(context)!;

    final user = ref.watch(userProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SectionTitle(
              icon: Icons.credit_card,
              title: l10n.userValidation.toUpperCase(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          CustomDropdownButton(
            title: l10n.documentIdType.toUpperCase(),
            value: user.idType.isEmpty ? null : user.idType,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldRequired(l10n.idType);
              }

              return null;
            },
            hideErrorText: false,
            items: [
              DropdownMenuItem(
                value: "National ID (PhilSys)",
                child: Text(l10n.idTypePhilsys),
              ),
              DropdownMenuItem(
                value: "Driver's License",
                child: Text(l10n.idTypeDriversLicense),
              ),
              DropdownMenuItem(
                value: "Passport",
                child: Text(l10n.idTypePassport),
              ),
            ],
            onChanged: (value) {
              ref.read(userProvider.notifier).setIDType(value!);
              setState(() => idCheckError = null);
            },
            isRequired: true,
          ),
          const SizedBox(
            height: 10,
          ),
          FormField<File>(
            key: ValueKey(user.idType), // resets the preview when the type changes
            initialValue: user.idImage,
            validator: (value) {
              if (value == null) {
                return l10n.fieldRequired(l10n.idPhoto);
              }
              return null;
            },
            builder: (field) {
              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: field.value != null
                                ? Image.file(
                                    field.value!,
                                    fit: BoxFit.cover,
                                  )
                                : (isCameraInitialized
                                      ? FittedBox(
                                          fit: BoxFit.cover,
                                          child: SizedBox(
                                            width: cameraController.value.previewSize!.height,
                                            height: cameraController.value.previewSize!.width,
                                            child: CameraPreview(cameraController),
                                          ),
                                        )
                                      : Container()),
                          ),
                          if (field.value == null) ...[
                            Positioned.fill(
                              child: CustomPaint(
                                painter: ScannerOverlayPainter(),
                                child: Container(),
                              ),
                            ),
                            Positioned(
                              top: 75,
                              left: 20,
                              right: 20,
                              child: Column(
                                children: [
                                  SizedBox(height: 8),
                                  Center(
                                    child: LabelText(
                                      value: l10n.alignId,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      onPressed: !isCameraInitialized || isProcessing || user.idType.isEmpty
                          ? null
                          : () async {
                              if (field.value != null) {
                                field.didChange(null);
                                setState(() => idCheckError = null);
                                return;
                              }

                              setState(() {
                                isProcessing = true;
                                idCheckError = null;
                              });

                              try {
                                final file = await takePicture();
                                final error = await getIDFromCard(file).timeout(const Duration(seconds: 15));

                                if (!mounted) return;

                                if (error != null) {
                                  setState(() => idCheckError = error);
                                  return;
                                }
                                field.didChange(file);
                              } on TimeoutException {
                                if (mounted) {
                                  setState(
                                    () => idCheckError =
                                        AppLocalizations.of(context)!.serverUnreachable,
                                  );
                                }
                              } catch (e) {
                                debugPrint('ID capture failed: $e');
                                if (mounted) {
                                  setState(() => idCheckError = AppLocalizations.of(context)!.somethingWentWrong);
                                }
                              } finally {
                                if (mounted) setState(() => isProcessing = false);
                              }
                            },

                      value: isProcessing ? l10n.checking : (field.value != null ? l10n.retakePhoto : l10n.captureId),
                    ),
                  ),
                  if (idCheckError != null) ...[
                    const SizedBox(height: 10),
                    LabelText(
                      value: idCheckError!,
                      color: Colors.red,
                    ),
                  ] else if (field.hasError) ...[
                    const SizedBox(height: 10),
                    LabelText(
                      value: field.errorText ?? "",
                      color: Colors.red,
                    ),
                  ],
                  if (field.value != null && user.idNumber.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    LabelText(
                      value: l10n.idNumberLabel(user.idNumber),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
