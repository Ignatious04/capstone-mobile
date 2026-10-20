import 'dart:async';

import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/controllers/victim_controllers.dart';
import 'package:capstone/core/enums/police_concern_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_dropdown_button.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/custom_text_field.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/utilities/priority_calculator.dart';
import 'package:capstone/features/public_user/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/public_user/reporting/providers/pending_attachments_provider.dart';
import 'package:capstone/core/shared/providers/location_provider.dart';
import 'package:capstone/core/shared/providers/report_provider.dart';
import 'package:capstone/features/public_user/reporting/views/select_location_screen.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/features/public_user/reporting/widgets/pending_attachments_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:capstone/core/shared/widgets/custom_alert_dialog.dart';

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
  bool _isPoliceEmergency = true;
  PoliceConcernTypeEnum? _policeConcernType;

  List<DropdownMenuItem<ServiceTypeEnum>> _emergencyTypes(AppLocalizations l10n) => [
    for (final type in const [ServiceTypeEnum.medical, ServiceTypeEnum.police, ServiceTypeEnum.fire])
      DropdownMenuItem(
        value: type,
        child: BodyText(value: type.label(l10n), isBold: true),
      ),
  ];

  Future<void> _pickAttachmentSource() async {
    final l10n = AppLocalizations.of(context)!;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(l10n.takePhoto),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    await ref.read(reportProvider.notifier).addAttachment(source);
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    incidentDescriptionController.dispose();
    additionalInformationController.dispose();
    super.dispose();
  }

  Widget showLoadingOverlay() {
    return LoadingOverlayWidget();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final attachmentsList = ref.watch(pendingAttachmentsProvider);
    final victimsList = ref.watch(reportProvider).victims;
    final location = ref.watch(locationStreamProvider);

    return Scaffold(
      appBar: CustomAppBar(value: l10n.emergencyReport),
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
                              SectionTitle(
                                icon: Icons.perm_device_information,
                                title: l10n.requiredInformation,
                              ),
                              const SizedBox(height: 10),
                              BodyText(
                                value: l10n.requiredNote.toUpperCase(),
                                color: Colors.red,
                                isBold: false,
                              ),
                              const SizedBox(height: 10),
                              CustomDropdownButton(
                                title: l10n.emergencyType.toUpperCase(),
                                validator: (value) {
                                  if (value == null) {
                                    return l10n.fieldRequired(l10n.emergencyType);
                                  }

                                  return null;
                                },
                                hideErrorText: false,
                                items: _emergencyTypes(l10n),
                                onChanged: (value) {
                                  ref.read(reportProvider.notifier).setIncidentType(value!);
                                  setState(() {
                                    _isPoliceEmergency = true;
                                    _policeConcernType = null;
                                  });
                                },
                                isRequired: true,
                              ),
                              const SizedBox(height: 10),
                              if (ref.watch(reportProvider).incidentType == ServiceTypeEnum.police) ...[
                                LabelText(value: l10n.isThisEmergency.toUpperCase(), color: Colors.black54),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: SegmentedButton<bool>(
                                    style: SegmentedButton.styleFrom(
                                      iconSize: 25,
                                      selectedBackgroundColor: Colors.deepOrange,
                                      selectedForegroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12.0),
                                        ),
                                      ),
                                    ),
                                    segments: [
                                      ButtonSegment(
                                        value: true,
                                        label: BodyText(
                                          value: l10n.emergency,
                                          isBold: true,
                                          color: _isPoliceEmergency ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      ButtonSegment(
                                        value: false,
                                        label: BodyText(
                                          value: l10n.nonEmergency,
                                          isBold: true,
                                          color: _isPoliceEmergency ? Colors.black : Colors.white,
                                        ),
                                      ),
                                    ],
                                    selected: {_isPoliceEmergency},
                                    onSelectionChanged: (selection) {
                                      setState(() {
                                        _isPoliceEmergency = selection.first;
                                      });
                                    },
                                  ),
                                ),
                                if (!_isPoliceEmergency) ...[
                                  const SizedBox(height: 10),
                                  CustomDropdownButton<PoliceConcernTypeEnum>(
                                    title: l10n.concernType.toUpperCase(),
                                    value: _policeConcernType,
                                    validator: (value) => value == null ? l10n.fieldRequired(l10n.concernType) : null,
                                    hideErrorText: false,
                                    isRequired: true,
                                    items: [
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.noiseComplaint,
                                        child: BodyText(value: l10n.concernNoiseComplaint, isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.lostItem,
                                        child: BodyText(value: l10n.concernLostItem, isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.minorDispute,
                                        child: BodyText(value: l10n.concernMinorDispute, isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.suspiciousActivity,
                                        child: BodyText(value: l10n.concernSuspiciousActivity, isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.vandalism,
                                        child: BodyText(value: l10n.concernVandalism, isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.requestForReport,
                                        child: BodyText(value: l10n.concernRequestForReport, isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.other,
                                        child: BodyText(value: l10n.concernOther, isBold: true),
                                      ),
                                    ],
                                    onChanged: (value) => setState(() => _policeConcernType = value),
                                  ),
                                ],
                              ],
                              const SizedBox(
                                height: 10,
                              ),
                              CustomTextField(
                                title: l10n.description.toUpperCase(),
                                controller: incidentDescriptionController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.fieldRequired(l10n.description);
                                  }

                                  return null;
                                },
                                hideErrorText: false,
                                keyboardType: TextInputType.multiline,
                                maxLines: 5,
                                vertical: 10,
                                isRequired: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              LabelText(
                                value: l10n.location.toUpperCase(),
                                color: Colors.black54,
                              ),
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
                                                extraMarkers: {
                                                  Marker(
                                                    markerId: const MarkerId('selected_location'),
                                                    position: _selectedLocation!,
                                                  ),
                                                },
                                              ),
                                              Positioned(
                                                right: 12,
                                                top: 12,
                                                child: Chip(
                                                  avatar: Icon(
                                                    Icons.edit_location_alt,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  label: BodyText(
                                                    value: l10n.changeLocation,
                                                    color: Colors.white,
                                                    isBold: true,
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
                              SectionTitle(
                                icon: Icons.question_mark,
                                title: l10n.optionalInformation,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                        ExpansionTile(
                          title: Align(
                            alignment: Alignment.centerLeft,
                            child: BodyText(
                              value: l10n.victimInformation,
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
                                value: l10n.add,
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
                                      title: l10n.victimName.toUpperCase(),
                                      controller: _controllers[index].victimNameController,
                                      onChanged: (value) {
                                        ref.read(reportProvider.notifier).updateVictimName(index, value);
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      title: l10n.description.toUpperCase(),
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
                                      value: l10n.remove,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        ExpansionTile(
                          title: Align(
                            alignment: Alignment.centerLeft,
                            child: BodyText(
                              value: l10n.attachments,
                            ),
                          ),
                          tilePadding: EdgeInsets.symmetric(horizontal: 20),
                          childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: CustomElevatedButton(
                                onPressed: _pickAttachmentSource,
                                value: l10n.addAttachment,
                              ),
                            ),
                            SizedBox(height: 10),
                            PendingAttachmentsGrid(
                              files: attachmentsList,
                              onRemove: (index) => ref.read(reportProvider.notifier).removeAttachment(index),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                        ExpansionTile(
                          title: Align(
                            alignment: Alignment.centerLeft,
                            child: BodyText(
                              value: l10n.additionalInformation,
                              isBold: false,
                            ),
                          ),
                          tilePadding: EdgeInsets.symmetric(horizontal: 20),
                          childrenPadding: EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            CustomTextField(
                              title: l10n.description.toUpperCase(),
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
                            child: CustomElevatedButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                FocusScope.of(context).requestFocus(FocusNode());

                                if (!(reportsFormKey.currentState?.validate() ?? false)) {
                                  return;
                                }

                                final confirmed = await showConfirmationDialog(
                                  context,
                                  title: l10n.submitReportPrompt,
                                  content: "${l10n.submitConfirmNote} ${l10n.responseTimeNotice}",
                                );

                                if (confirmed != true) {
                                  return;
                                }

                                if (!location.hasValue) {
                                  CustomSnackbar(text: l10n.unableToGetLocation);
                                  return;
                                }

                                if (!context.mounted) {
                                  return;
                                }

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => showLoadingOverlay(),
                                );

                                try {
                                  await ref
                                      .read(reportProvider.notifier)
                                      .submitReport(
                                        description: incidentDescriptionController.text,
                                        additionalInformation: additionalInformationController.text,
                                        selectedLocation: _selectedLocation!,
                                        priority: PriorityCalculator.forManualReport(
                                          ref.read(reportProvider).incidentType!,
                                          isPoliceEmergency: _isPoliceEmergency,
                                        ),
                                        policeConcernType:
                                            ref.read(reportProvider).incidentType == ServiceTypeEnum.police &&
                                                !_isPoliceEmergency
                                            ? _policeConcernType
                                            : null,
                                      );

                                  if (!context.mounted) {
                                    return;
                                  }

                                  final submittedIncidentType = ref.read(reportProvider).incidentType!;
                                  final isNonEmergencyPolice =
                                      submittedIncidentType == ServiceTypeEnum.police && !_isPoliceEmergency;

                                  CustomSnackbarHelper.show(context, text: l10n.reportSentSuccess);
                                  Navigator.pop(context); // dismiss loading overlay

                                  if (!isNonEmergencyPolice && context.mounted) {
                                    await EmergencyGuidanceSheet.show(context, submittedIncidentType);
                                  }

                                  if (!context.mounted) {
                                    return;
                                  }

                                  Navigator.pop(context, true);
                                } on TimeoutException {
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  CustomSnackbarHelper.show(context, text: l10n.reportTimeoutError);
                                } catch (e, stack) {
                                  debugPrint("ERROR: $e");
                                  debugPrintStack(stackTrace: stack);
                                  if (!context.mounted) {
                                    return;
                                  }

                                  Navigator.pop(context);

                                  CustomSnackbarHelper.show(
                                    context,
                                    text: l10n.reportSendError,
                                  );
                                }
                              },
                              value: l10n.submitReport,
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
