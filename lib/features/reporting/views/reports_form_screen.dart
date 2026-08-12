import 'dart:math';

import 'package:capstone/core/controllers/victim_controllers.dart';
import 'package:capstone/core/enums/guidance_type_enum.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/core/shared/widgets/text/button_text.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/features/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/reporting/providers/pending_attachments_provider.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/features/reporting/providers/report_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/reporting/providers/report_repository_provider.dart';
import 'package:capstone/features/reporting/providers/storage_repository_provider.dart';
import 'package:capstone/features/reporting/views/select_location_screen.dart';
import 'package:capstone/features/reporting/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ReportsFormScreen extends ConsumerStatefulWidget {
  const ReportsFormScreen({super.key});

  @override
  ConsumerState<ReportsFormScreen> createState() => _ReportsFormScreenState();
}

class _ReportsFormScreenState extends ConsumerState<ReportsFormScreen> {
  final TextEditingController incidentDescriptionController = TextEditingController();
  final TextEditingController additionalInformationController = TextEditingController();
  final List<VictimControllers> _controllers = [];
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  final reportsFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
    incidentDescriptionController.dispose();
    additionalInformationController.dispose();
  }

  Widget showLoadingOverlay() {
    return LoadingOverlayWidget();
  }

  @override
  Widget build(BuildContext context) {
    final attachmentsList = ref.watch(pendingAttachmentsProvider);
    final victimsList = ref.watch(reportProvider).victims;
    final location = ref.watch(locationStreamProvider);

    return Scaffold(
      appBar: CustomAppBar(value: "Emergency Report"),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Form(
                  key: reportsFormKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionTitle(
                                icon: Icons.perm_device_information,
                                title: "Required Information",
                              ),
                              const SizedBox(height: 10),
                              const SupportingInfoText(
                                value: "NOTE: REQUIRED FIELDS ARE DENOTED BY AN ASTERISK (*)",
                                color: Colors.red,
                                isBold: false,
                              ),
                              const SizedBox(height: 10),
                              CustomDropdownButton(
                                title: "EMERGENCY TYPE",
                                validator: (value) {
                                  if (value == null) {
                                    return "Emergency type is required";
                                  }

                                  return null;
                                },
                                hideErrorText: false,
                                items: [
                                  const DropdownMenuItem(
                                    value: GuidanceTypeEnum.medical,
                                    child: Text("Medical"),
                                  ),
                                  const DropdownMenuItem(
                                    value: GuidanceTypeEnum.police,
                                    child: Text("Police"),
                                  ),
                                  const DropdownMenuItem(
                                    value: GuidanceTypeEnum.fire,
                                    child: Text("Fire"),
                                  ),
                                ],
                                onChanged: (value) {
                                  ref.read(reportProvider.notifier).setIncidentType(value!);
                                },
                                isRequired: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                title: "DESCRIPTION",
                                controller: incidentDescriptionController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Description is required";
                                  }

                                  return null;
                                },
                                hideErrorText: false,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                vertical: 20,
                                isRequired: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const DataLabelText(value: "LOCATION"),
                              const SizedBox(
                                height: 10,
                              ),
                              location.when(
                                loading: () => const SizedBox(
                                  height: 250,
                                  child: Center(
                                    child: CustomCircularProgressIndicator(),
                                  ),
                                ),
                                error: (error, stack) => SizedBox(
                                  height: 250,
                                  child: Center(
                                    child: Text(error.toString()),
                                  ),
                                ),
                                data: (latLng) {
                                  _selectedLocation ??= latLng;
                                  return Align(
                                    alignment: Alignment.center,
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 1,
                                      margin: EdgeInsets.zero,
                                      clipBehavior: Clip.antiAlias,
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 250,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () async {
                                            final LatLng? location = await Navigator.push<LatLng>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => SelectLocationScreen(
                                                  initialLocation: _selectedLocation!,
                                                ),
                                              ),
                                            );
                                            if (location != null) {
                                              setState(() {
                                                _selectedLocation = location;
                                              });

                                              _mapController?.animateCamera(CameraUpdate.newLatLng(location));
                                            }
                                          },
                                          child: Stack(
                                            children: [
                                              MapTileWidget(
                                                initialLocation: _selectedLocation!,
                                                mode: MapModeEnum.view,
                                                onMapCreated: (controller) {
                                                  _mapController = controller;
                                                },
                                              ),
                                              Positioned(
                                                right: 12,
                                                top: 12,
                                                child: const Chip(
                                                  avatar: Icon(
                                                    Icons.edit_location_alt,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  label: ButtonText(
                                                    value: "Change location",
                                                    color: Colors.white,
                                                  ),
                                                  backgroundColor: Colors.deepOrange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SectionTitle(
                                icon: Icons.question_mark,
                                title: "Optional Information",
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        ExpansionTile(
                          title: const Align(
                            alignment: Alignment.centerLeft,
                            child: ButtonText(
                              value: 'Victim Information',
                            ),
                          ),
                          tilePadding: EdgeInsets.symmetric(horizontal: 20),
                          childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CustomElevatedButton(
                                onPressed: () {
                                  ref.read(reportProvider.notifier).addVictim();

                                  setState(() {
                                    _controllers.add(VictimControllers());
                                  });
                                },
                                value: "Add",
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...List.generate(
                              victimsList.length,
                              (index) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      title: "VICTIM NAME",
                                      controller: _controllers[index].victimNameController,
                                      onChanged: (value) {
                                        ref.read(reportProvider.notifier).updateVictimName(index, value);
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      title: "DESCRIPTION",
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 5,
                                      vertical: 30,
                                      controller: _controllers[index].victimDescriptionController,
                                      onChanged: (value) {
                                        ref
                                            .read(reportProvider.notifier)
                                            .updateVictimDescription(
                                              index,
                                              value,
                                            );
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    CustomElevatedButton(
                                      onPressed: () {
                                        _controllers[index].dispose();

                                        setState(() {
                                          _controllers.removeAt(index);
                                        });

                                        ref.read(reportProvider.notifier).removeVictim(index);
                                      },
                                      value: "Remove",
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Align(
                            alignment: Alignment.centerLeft,
                            child: ButtonText(
                              value: 'Attachments',
                            ),
                          ),
                          tilePadding: EdgeInsets.symmetric(horizontal: 20),
                          childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CustomElevatedButton(
                                onPressed: () async {
                                  ref.read(reportProvider.notifier).addAttachment(ImageSource.gallery);
                                },
                                value: "Add attachment",
                              ),
                            ),
                            SizedBox(height: 10),
                            ...List.generate(
                              attachmentsList.length,
                              (index) {
                                final attachment = attachmentsList[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ),
                                      child: Container(
                                        color: AppColors.lighterBlack,
                                        width: 300,
                                        height: 300,
                                        child: Image.file(
                                          attachment,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.lighterBlack,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        ref.read(reportProvider.notifier).removeAttachment(index);
                                      },
                                      child: const Text(
                                        "Remove attachment",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: const Align(
                            alignment: Alignment.centerLeft,
                            child: ButtonText(
                              value: "Additional Information",
                              isBold: false,
                            ),
                          ),
                          tilePadding: EdgeInsets.symmetric(horizontal: 20),
                          childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            CustomTextField(
                              title: "DESCRIPTION",
                              controller: additionalInformationController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              vertical: 20,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                FocusScope.of(context).requestFocus(FocusNode());

                                if (!(reportsFormKey.currentState?.validate() ?? false)) {
                                  return;
                                }

                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const SupportingInfoText(
                                        value: "Are you sure that you wish to submit this report?",
                                      ),
                                      content: const Text("Put disclaimer here..."),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepOrange,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text("No"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepOrange,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text("Yes"),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed != true) {
                                  return;
                                }

                                showDialog(
                                  context: this.context,
                                  barrierDismissible: false,
                                  builder: (context) => showLoadingOverlay(),
                                );

                                try {
                                  final reportID = ref.read(reportRepositoryProvider).getReportID();
                                  final now = DateTime.now();
                                  final date =
                                      '${now.year}'
                                      '${now.month.toString().padLeft(2, '0')}'
                                      '${now.day.toString().padLeft(2, '0')}';

                                  ref.read(reportProvider.notifier).setLocation(_selectedLocation!);

                                  final attachments = await ref
                                      .read(storageRepositoryProvider)
                                      .uploadAttachments(
                                        reportID: reportID,
                                        files: ref.read(pendingAttachmentsProvider),
                                      );

                                  final report = ref
                                      .read(reportProvider)
                                      .copyWith(
                                        reportID: reportID,
                                        referenceNumber: "RPT-$date-${Random().nextInt(900000) + 100000}",
                                        userID: ref.read(firebaseAuthProvider).currentUser!.uid.toString(),
                                        description: incidentDescriptionController.text,
                                        attachments: attachments,
                                        additionalInformation: additionalInformationController.text,
                                        status: ReportStatusEnum.pending,
                                        createdAt: now,
                                      );

                                  await ref.read(reportRepositoryProvider).createReport(report);

                                  ref.read(pendingAttachmentsProvider.notifier).state = [];

                                  if (!context.mounted) {
                                    return;
                                  }

                                  CustomSnackbarHelper.show(context, text: "Report sent successfully!");
                                  Navigator.pop(context);
                                  Navigator.pop(context, true);
                                } catch (e, stack) {
                                  debugPrint("ERROR: $e");
                                  debugPrintStack(stackTrace: stack);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: ButtonText(
                                value: "Submit Report",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
