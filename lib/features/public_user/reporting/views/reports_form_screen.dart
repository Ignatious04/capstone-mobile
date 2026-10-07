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
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/reporting/views/select_location_screen.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
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

  static const _emergencyType = [
    DropdownMenuItem(
      value: ServiceTypeEnum.medical,
      child: BodyText(
        value: "Medical",
        isBold: true,
      ),
    ),
    DropdownMenuItem(
      value: ServiceTypeEnum.police,
      child: BodyText(
        value: "Police",
        isBold: true,
      ),
    ),
    DropdownMenuItem(
      value: ServiceTypeEnum.fire,
      child: BodyText(
        value: "Fire",
        isBold: true,
      ),
    ),
  ];

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
                              const BodyText(
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
                                items: _emergencyType,
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
                                const LabelText(value: "IS THIS AN EMERGENCY?", color: Colors.black54),
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
                                          value: "Emergency",
                                          isBold: true,
                                          color: _isPoliceEmergency ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      ButtonSegment(
                                        value: false,
                                        label: BodyText(
                                          value: "Non-emergency",
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
                                    title: "CONCERN TYPE",
                                    value: _policeConcernType,
                                    validator: (value) => value == null ? "Concern type is required" : null,
                                    hideErrorText: false,
                                    isRequired: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.noiseComplaint,
                                        child: BodyText(value: "Noise complaint", isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.lostItem,
                                        child: BodyText(value: "Lost/stolen item", isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.minorDispute,
                                        child: BodyText(value: "Minor dispute", isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.suspiciousActivity,
                                        child: BodyText(value: "Suspicious activity", isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.vandalism,
                                        child: BodyText(value: "Vandalism", isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.requestForReport,
                                        child: BodyText(value: "Request for a police report", isBold: true),
                                      ),
                                      DropdownMenuItem(
                                        value: PoliceConcernTypeEnum.other,
                                        child: BodyText(value: "Other", isBold: true),
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
                                vertical: 10,
                                isRequired: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const LabelText(
                                value: "LOCATION",
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
                                                child: const Chip(
                                                  avatar: Icon(
                                                    Icons.edit_location_alt,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  label: BodyText(
                                                    value: "Change location",
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
                            child: BodyText(
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
                            child: BodyText(
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
                            child: BodyText(
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
                            child: CustomElevatedButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                FocusScope.of(context).requestFocus(FocusNode());

                                if (!(reportsFormKey.currentState?.validate() ?? false)) {
                                  return;
                                }

                                final confirmed = await showConfirmationDialog(
                                  context,
                                  title: "Do you wish to submit this report?",
                                  content:
                                      "By submitting, you confirm that this report is accurate. "
                                      "Angeles City's declared emergency response time is 10–15 minutes; "
                                      "please note that actual response time may vary depending on "
                                      "responder availability, traffic, and the nature of each case.",
                                );

                                if (confirmed != true) {
                                  return;
                                }

                                if (!location.hasValue) {
                                  CustomSnackbar(text: "Unable to get your current location.");
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
                                        priority: PriorityCalculator.forManualReport(ref.read(reportProvider).incidentType!, isPoliceEmergency: _isPoliceEmergency),
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

                                  CustomSnackbarHelper.show(context, text: "Report sent successfully!");
                                  Navigator.pop(context); // dismiss loading overlay

                                  if (!isNonEmergencyPolice && context.mounted) {
                                    await EmergencyGuidanceSheet.show(context, submittedIncidentType);
                                  }

                                  if (!context.mounted) {
                                    return;
                                  }

                                  Navigator.pop(context, true);
                                } catch (e, stack) {
                                  debugPrint("ERROR: $e");
                                  debugPrintStack(stackTrace: stack);
                                  if (!context.mounted) {
                                    return;
                                  }

                                  Navigator.pop(context);

                                  CustomSnackbarHelper.show(
                                    context,
                                    text: "An error has occurred while trying to send your report!",
                                  );
                                }
                              },
                              value: "Submit Report",
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
