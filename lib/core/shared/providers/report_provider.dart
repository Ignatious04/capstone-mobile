import 'dart:io';
import 'package:capstone/core/constants/timeouts.dart';
import 'package:capstone/core/enums/police_concern_enum.dart';
import 'package:capstone/core/enums/report_priority_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/utilities/priority_calculator.dart';
import 'package:capstone/core/utilities/reference_number_generator.dart';
import 'package:capstone/core/shared/models/report_model.dart';
import 'package:capstone/features/public_user/reporting/models/victim_model.dart';
import 'package:capstone/features/public_user/reporting/providers/pending_attachments_provider.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:capstone/core/shared/providers/storage_repository_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

final reportProvider = NotifierProvider<ReportNotifier, ReportModel>(
  ReportNotifier.new,
);

class ReportNotifier extends Notifier<ReportModel> {
  @override
  ReportModel build() {
    return const ReportModel();
  }

  Future<void> submitReport({
    required String description,
    required LatLng selectedLocation,
    required String additionalInformation,
    ReportPriorityEnum? priority,
    PoliceConcernTypeEnum? policeConcernType,
  }) {
    return ref.read(auditLogRepositoryProvider).trackFailure(
      "normal",
      () async {
        if (!ref.read(isVerifiedProvider)) throw NotVerifiedException();
        final reportRepository = ref.read(reportRepositoryProvider);
        final storageRepository = ref.read(storageRepositoryProvider);
        // final realtimeRepository = ref.read(realtimeDatabaseRepositoryProvider);
        final userID = ref.read(firebaseAuthProvider).currentUser!.uid;

        final now = DateTime.now();
        final reportID = state.reportID.isNotEmpty ? state.reportID : reportRepository.getReportID();
        final referenceNumber = state.referenceNumber.isNotEmpty
            ? state.referenceNumber
            : ReferenceNumberGenerator.generate(now);
        // Remember the IDs so a retry after a timeout reuses them.
        state = state.copyWith(reportID: reportID, referenceNumber: referenceNumber);
        setLocation(selectedLocation);

        final attachments = await storageRepository.uploadAttachments(
          reportID: reportID,
          files: ref.read(pendingAttachmentsProvider),
        );

        final report = state.copyWith(
          reportID: reportID,
          referenceNumber: referenceNumber,
          userID: userID,
          priority: priority,
          policeConcernType: policeConcernType,
          description: description,
          attachments: attachments,
          additionalInformation: additionalInformation,
          status: ReportStatusEnum.pending,
          createdAt: now,
        );

        debugPrint('submitReport: writing ${report.reportID}');
        await reportRepository.createReport(report).timeout(kReportWriteTimeout);
        debugPrint('submitReport: write acknowledged');

        // Sent successfully: clear them so the next report gets fresh IDs.
        state = state.copyWith(reportID: '', referenceNumber: '');

        // final realtimeReport = RealtimeReportModel(
        //   reportID: report.reportID,
        //   referenceNumber: report.referenceNumber,
        //   status: report.status ?? ReportStatusEnum.pending,
        //   latitude: report.location?.latitude ?? 0,
        //   longitude: report.location?.longitude ?? 0,
        //   updatedAt: DateTime.now(),
        // );

        // await realtimeRepository.create(path: "activeReports/${report.reportID}", data: realtimeReport.toMap());

        ref.read(pendingAttachmentsProvider.notifier).state = [];
      },
    );
  }

  Future<void> submitQuickReport({
    required ServiceTypeEnum incidentType,
    required LatLng location,
  }) {
    return ref.read(auditLogRepositoryProvider).trackFailure(
      "quick",
      () async {
        if (!ref.read(isVerifiedProvider)) throw NotVerifiedException();
        final reportRepository = ref.read(reportRepositoryProvider);
        // final realtimeRepository = ref.read(realtimeDatabaseRepositoryProvider);
        final userID = ref.read(firebaseAuthProvider).currentUser!.uid;

        final now = DateTime.now();
        final reportID = state.reportID.isNotEmpty ? state.reportID : reportRepository.getReportID();
        final referenceNumber = state.referenceNumber.isNotEmpty
            ? state.referenceNumber
            : ReferenceNumberGenerator.generate(now);
        // Remember the IDs so a retry after a timeout reuses them.
        state = state.copyWith(reportID: reportID, referenceNumber: referenceNumber);

        final report = ReportModel(
          reportID: reportID,
          referenceNumber: referenceNumber,
          userID: userID,
          reportType: ReportTypeEnum.quick,
          incidentType: incidentType,
          priority: PriorityCalculator.forQuickReport(incidentType),
          status: ReportStatusEnum.pending,
          location: GeoPoint(location.latitude, location.longitude),
          createdAt: now,
        );

        debugPrint('submitReport: writing ${report.reportID}');
        await reportRepository.createReport(report).timeout(kReportWriteTimeout);
        debugPrint('submitReport: write acknowledged');

        // Sent successfully: clear them so the next report gets fresh IDs.
        state = state.copyWith(reportID: '', referenceNumber: '');

        // final realtimeReport = RealtimeReportModel(
        //   reportID: report.reportID,
        //   referenceNumber: report.referenceNumber,
        //   status: report.status ?? ReportStatusEnum.pending,
        //   latitude: report.location?.latitude ?? 0,
        //   longitude: report.location?.longitude ?? 0,
        //   updatedAt: now,
        // );

        // await realtimeRepository.create(path: "activeReports/${report.reportID}", data: realtimeReport.toMap());
      },
    );
  }

  void setIncidentType(ServiceTypeEnum value) {
    state = state.copyWith(incidentType: value);
  }

  void setLocation(LatLng location) {
    state = state.copyWith(
      location: GeoPoint(
        location.latitude,
        location.longitude,
      ),
    );
  }

  void addVictim() {
    state = state.copyWith(
      victims: [
        ...state.victims,
        const VictimModel(),
      ],
    );
  }

  void removeVictim(int index) {
    final victims = [...state.victims];
    victims.removeAt(index);
    state = state.copyWith(victims: victims);
  }

  void updateVictimName(int index, String value) {
    final victims = [...state.victims];

    victims[index] = victims[index].copyWith(
      name: value,
    );

    state = state.copyWith(victims: victims);
  }

  void updateVictimDescription(int index, String value) {
    final victims = [...state.victims];

    victims[index] = victims[index].copyWith(
      description: value,
    );

    state = state.copyWith(victims: victims);
  }

  Future<void> addAttachment(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 1920,
    );

    if (image == null) return;

    final file = File(image.path);

    ref
        .read(pendingAttachmentsProvider.notifier)
        .update(
          (state) => [...state, file],
        );
  }

  void removeAttachment(int index) {
    ref.read(pendingAttachmentsProvider.notifier).update(
      (state) {
        final attachments = [...state];
        attachments.removeAt(index);
        return attachments;
      },
    );
  }
}
