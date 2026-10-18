import 'package:capstone/core/constants/timeouts.dart';
import 'package:capstone/core/enums/audit_action_enum.dart';
import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/audit_log_repository_provider.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/utilities/priority_calculator.dart';
import 'package:capstone/core/utilities/reference_number_generator.dart';
import 'package:capstone/core/utilities/sms_launcher.dart';
import 'package:capstone/features/public_user/map/providers/contact_number_repository_provider.dart';
import 'package:capstone/features/public_user/pre_call_guidance/models/pre_call_guidance_model.dart';
import 'package:capstone/features/public_user/pre_call_guidance/models/question_state.dart';
import 'package:capstone/core/shared/providers/report_provider.dart';
import 'package:capstone/core/shared/providers/report_repository_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final guidanceProvider = NotifierProvider<GuidanceNotifier, QuestionState>(
  GuidanceNotifier.new,
);

class GuidanceNotifier extends Notifier<QuestionState> {
  // IDs of a submit attempt that hasn't been confirmed yet. Reused on retry so
  // a timed-out (but still queued) write is overwritten instead of duplicated.
  String? _pendingReportID;
  String? _pendingReferenceNumber;
  DateTime? _pendingCreatedAt;
  static const _pendingTtl = Duration(minutes: 10);

  void _clearPending() {
    _pendingReportID = null;
    _pendingReferenceNumber = null;
    _pendingCreatedAt = null;
  }

  @override
  QuestionState build() {
    return QuestionState(
      questions: [],
      currentPage: 0,
    );
  }

  void resetAnswers() {
    state = state.copyWith(
      currentPage: 0,
      questions: [
        for (final question in state.questions) question.copyWith(answer: null),
      ],
    );
  }

  Future<bool> submitGuidanceReport({
    required LatLng location,
    required bool isOnline,
    LatLng? originalGPS,
    double? accuracy,
    String? locationNote,
  }) {
    return ref.read(auditLogRepositoryProvider).trackFailure(
      "preCallGuidance",
      () async {
        final incidentType = ref.read(reportProvider).incidentType;

        if (incidentType == null) {
          throw Exception('No incident type selected.');
        }

        final now = DateTime.now();
        final hasPending = _pendingCreatedAt != null && now.difference(_pendingCreatedAt!) < _pendingTtl;
        if (!hasPending) {
          _pendingReportID = null;
          _pendingReferenceNumber = ReferenceNumberGenerator.generate(now);
          _pendingCreatedAt = now;
        }
        final referenceNumber = _pendingReferenceNumber!;

        if (!isOnline) {
          if (!ref.read(isVerifiedProvider)) throw NotVerifiedException();
          await _submitViaSms(
            incidentType: incidentType,
            referenceNumber: referenceNumber,
            location: location,
            locationNote: locationNote,
          );
          _clearPending();
          return true;
        }

        final reportRepository = ref.read(reportRepositoryProvider);
        // final realtimeRepository = ref.read(realtimeDatabaseRepositoryProvider);
        final userID = ref.read(firebaseAuthProvider).currentUser!.uid;
        final reportID = _pendingReportID ??= reportRepository.getReportID();

        final report = ref
            .read(reportProvider)
            .copyWith(
              reportID: reportID,
              referenceNumber: referenceNumber,
              userID: userID,
              reportType: ReportTypeEnum.preCallGuidance,
              guidanceAnswers: state.questions,
              priority: PriorityCalculator.forGuidance(incidentType, state.questions),
              status: ReportStatusEnum.pending,
              location: GeoPoint(location.latitude, location.longitude),
              locationAccuracy: accuracy,
              locationDescription: (locationNote == null || locationNote.isEmpty) ? null : locationNote,
              originalGpsLocation: originalGPS == null ? null : GeoPoint(originalGPS.latitude, originalGPS.longitude),
              createdAt: _pendingCreatedAt,
            );

        await reportRepository.createReport(report).timeout(kReportWriteTimeout);
        _clearPending();

        // final realtimeReport = RealtimeReportModel(
        //   reportID: report.reportID,
        //   referenceNumber: report.referenceNumber,
        //   status: report.status ?? ReportStatusEnum.pending,
        //   latitude: report.location?.latitude ?? 0,
        //   longitude: report.location?.longitude ?? 0,
        //   updatedAt: DateTime.now(),
        // );

        // await realtimeRepository.create(path: "activeReports/${report.reportID}", data: realtimeReport.toMap());

        return false;
      },
    );
  }

  Future<void> _submitViaSms({
    required ServiceTypeEnum incidentType,
    required String referenceNumber,
    required LatLng location,
    String? locationNote,
  }) async {
    final number = await ref.read(contactNumberRepositoryProvider).getNumber(incidentType);
    final user = ref.read(currentAuthenticatedUserProvider).value;

    if (user == null) {
      throw Exception('No authenticated user found.');
    }

    if (number == null) {
      throw Exception(
        'No cached contact number available for offline reporting. Please connect to the internet at least once.',
      );
    }

    final buffer = StringBuffer()
      ..writeln('Ref: $referenceNumber')
      ..writeln('User ID: ${user.userID}')
      ..writeln('Reporter: ${user.firstName} ${user.lastName}')
      ..writeln('Type: ${incidentType.name.toUpperCase()}');

    for (final q in state.questions) {
      final answer = q.answer == null ? 'Not answered' : (q.answer! ? 'Yes' : 'No');
      buffer.writeln('${q.question} $answer');
    }

    // Plain decimal degrees ("lat, lng") so the dispatcher can paste both numbers
    // straight into the Latitude box of the Log SMS Report form.
    if (locationNote != null && locationNote.isNotEmpty) {
      buffer.writeln('Landmark: $locationNote');
    }
    buffer.writeln('Location: ${location.latitude.toStringAsFixed(7)}, ${location.longitude.toStringAsFixed(7)}');

    ref
        .read(auditLogRepositoryProvider)
        .log(
          AuditAction.smsFallbackLaunched,
          targetType: 'report',
          metadata: {
            'referenceNumber': referenceNumber,
            'incidentType': incidentType.name,
            'destination': number,
          },
        );
    await launchSms(number, buffer.toString());
  }

  void loadQuestions(ServiceTypeEnum type) {
    switch (type) {
      case ServiceTypeEnum.medical:
        state = QuestionState(
          currentPage: 0,
          questions: [
            PreCallGuidanceModel(id: 'medical_conscious', question: "Is the person conscious?"),
            PreCallGuidanceModel(id: 'medical_life_threatening', question: "Is there life threatening injuries?"),
            PreCallGuidanceModel(id: 'medical_intentional', question: "Is their current condition intentional?"),
          ],
        );
        break;

      case ServiceTypeEnum.police:
        state = QuestionState(
          currentPage: 0,
          questions: [
            PreCallGuidanceModel(id: 'police_suspect_present', question: "Is the suspect present?"),
            PreCallGuidanceModel(id: 'police_weapons', question: "Are there weapons involved?"),
            PreCallGuidanceModel(id: 'police_injured', question: "Is someone injured?"),
          ],
        );
        break;

      case ServiceTypeEnum.fire:
        state = QuestionState(
          currentPage: 0,
          questions: [
            PreCallGuidanceModel(id: 'fire_trapped', question: "Are there people trapped inside?"),
            PreCallGuidanceModel(id: 'fire_spreading', question: "Is the fire spreading?"),
          ],
        );
        break;
    }
  }

  void answerQuestion(int index, bool answer) {
    final updatedQuestions = [...state.questions];

    updatedQuestions[index] = updatedQuestions[index].copyWith(answer: answer);

    state = state.copyWith(
      questions: updatedQuestions,
    );
  }

  void setCurrentPage(int page) {
    state = state.copyWith(
      currentPage: page,
    );
  }

  void nextPage() {
    if (state.currentPage < state.questions.length - 1) {
      state = state.copyWith(
        currentPage: state.currentPage + 1,
      );
    }
  }
}
