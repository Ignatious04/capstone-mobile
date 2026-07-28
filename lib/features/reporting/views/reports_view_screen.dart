import 'package:capstone/core/enums/map_mode_enum.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/loading_overlay_widget.dart';
import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/text_title_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/map/widgets/map_tile_widget.dart';
import 'package:capstone/features/reporting/models/report_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReportsViewScreen extends StatelessWidget {
  const ReportsViewScreen({super.key, required this.report});

  final ReportModel report;

  Widget showLoadingOverlay() {
    return LoadingOverlayWidget();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(report.attachments.toString());
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const TextTitleSmall(
          title: "Back",
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                        const TextTitleMedium(
                          title: "Required Information",
                          isBold: true,
                        ),
                        const SizedBox(height: 10),
                        const TextBodySmall(title: "Emergency Type"),
                        TextBodyMedium(
                          title: report.type!.name,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const TextBodySmall(title: "Description"),
                        TextBodyMedium(
                          title: report.description,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const TextBodySmall(title: "Location"),
                        Align(
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: MapTileWidget(
                                initialLocation: LatLng(
                                  report.location!.latitude,
                                  report.location!.longitude,
                                ),
                                mode: MapModeEnum.view,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const TextTitleMedium(
                          title: "Optional Information",
                          isBold: true,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextBodySmall(title: "Victims"),
                        if (report.victims.isEmpty) ...[
                          const TextBodyMedium(title: "No victim information provided."),
                        ] else
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.lighterBlack,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0; i < report.victims.length; i++) ...[
                                    TextBodyMedium(
                                      title: "Name: ${report.victims[i].name}",
                                    ),
                                    TextBodyMedium(
                                      title: "Description: ${report.victims[i].description}",
                                    ),
                                    if (i != report.victims.length - 1) const SizedBox(height: 10),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        const TextBodySmall(title: "Attachments"),
                        if (report.attachments.isEmpty) ...[
                          const TextBodyMedium(
                            title: "No attachments provided.",
                          ),
                        ] else
                          Column(
                            children: [
                              for (final url in report.attachments) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 300,
                                    height: 300,
                                    color: AppColors.lighterBlack,
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return const Center(
                                          child: CustomCircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            size: 50,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        const SizedBox(
                          height: 10,
                        ),
                        const TextBodySmall(
                          title: "Additional Information",
                        ),
                        if (report.additionalInformation.isEmpty) ...[
                          const TextBodyMedium(title: "No additional information provided."),
                        ] else
                          TextBodyMedium(title: report.additionalInformation),
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
