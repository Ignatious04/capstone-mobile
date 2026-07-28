import 'dart:math';

import 'package:capstone/core/controllers/victim_controllers.dart';
import 'package:capstone/core/enums/guidance_type_enum.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/features/map/widgets/map_tile_widget.dart';
import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/features/reporting/providers/pending_attachments_provider.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/features/reporting/providers/report_provider.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/reporting/providers/report_repository_provider.dart';
import 'package:capstone/features/reporting/providers/storage_repository_provider.dart';
import 'package:capstone/features/reporting/views/select_location_screen.dart';
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
  TextEditingController incidentDescriptionController = TextEditingController();
  TextEditingController additionalInformationController = TextEditingController();
  final List<VictimControllers> _controllers = [];
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

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
      appBar: AppBar(
        toolbarHeight: 40,
        title: Text(
          textAlign: TextAlign.left,
          "Back",
          style:
              Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(
                color: Colors.white,
              ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(title: "Emergency Report", body: "Describe your situation and let us know"),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextTitleSmall(
                          title: "Required Information",
                          isBold: false,
                        ),
                        SizedBox(height: 10),
                        CustomDropdownButton(
                          title: "EMERGENCY TYPE",
                          items: [
                            DropdownMenuItem(
                              value: GuidanceTypeEnum.medical,
                              child: Text("Medical"),
                            ),
                            DropdownMenuItem(
                              value: GuidanceTypeEnum.police,
                              child: Text("Police"),
                            ),
                            DropdownMenuItem(
                              value: GuidanceTypeEnum.fire,
                              child: Text("Fire"),
                            ),
                          ],
                          onChanged: (value) {
                            ref.read(reportProvider.notifier).setEmergencyType(value!);
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CustomTextField(
                          title: "DESCRIPTION",
                          controller: incidentDescriptionController,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          vertical: 30,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextBodySmall(title: "LOCATION"),
                        SizedBox(
                          height: 10,
                        ),
                        location.when(
                          loading: () => const SizedBox(
                            height: 250,
                            child: Center(
                              child: CircularProgressIndicator(),
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
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
                                          child: Chip(
                                            avatar: Icon(Icons.edit_location_alt, size: 18),
                                            label: Text("Change location"),
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
                        SizedBox(
                          height: 10,
                        ),
                        TextTitleSmall(
                          title: "Optional Information",
                          isBold: false,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ExpansionTile(
                          title: TextTitleSmall(
                            title: "Victim Information",
                            isBold: false,
                          ),
                          tilePadding: EdgeInsets.all(0),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lighterBlack,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  ref.read(reportProvider.notifier).addVictim();

                                  setState(() {
                                    _controllers.add(VictimControllers());
                                  });
                                },
                                child: Text("Add"),
                              ),
                            ),
                            SizedBox(height: 10),
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
                                    SizedBox(height: 10),
                                    CustomTextField(
                                      title: "VICTIM NAME",
                                      controller: _controllers[index].victimNameController,
                                      onChanged: (value) {
                                        ref.read(reportProvider.notifier).updateVictimName(index, value);
                                      },
                                    ),
                                    SizedBox(height: 10),
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
                                    SizedBox(height: 10),
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
                                        _controllers[index].dispose();

                                        setState(() {
                                          _controllers.removeAt(index);
                                        });

                                        ref.read(reportProvider.notifier).removeVictim(index);
                                      },
                                      child: Text("Remove"),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: TextTitleSmall(
                            title: "Attachments",
                            isBold: false,
                          ),
                          tilePadding: EdgeInsets.all(0),
                          childrenPadding: EdgeInsets.all(0),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lighterBlack,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  ref.read(reportProvider.notifier).addAttachment(ImageSource.gallery);
                                },
                                child: Text("Add attachment"),
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
                                    SizedBox(
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
                                    SizedBox(
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
                                      child: Text(
                                        "Remove attachment",
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: TextTitleSmall(
                            title: "Additional Information",
                            isBold: false,
                          ),
                          tilePadding: EdgeInsets.all(0),
                          children: [
                            CustomTextField(
                              title: "DESCRIPTION",
                              controller: additionalInformationController,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              vertical: 30,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              FocusScope.of(context).requestFocus(FocusNode());
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: TextTitleSmall(
                                      title: "Are you sure that you wish to submit this report?",
                                    ),
                                    content: Text("Put disclaimer here..."),
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
                                        child: Text("No"),
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
                                        child: Text("Yes"),
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

                                final attachmentUrls = await ref
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
                                      attachments: attachmentUrls,
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
                                Navigator.pop(context);
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
                            child: Text("Submit Report"),
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
