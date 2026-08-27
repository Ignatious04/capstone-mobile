import 'package:capstone/core/enums/report_status_enum.dart';
import 'package:capstone/core/enums/report_type_enum.dart';
import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/utilities/reference_number_generator.dart';
import 'package:capstone/features/public_user/pre_call_guidance/models/pre_call_guidance_model.dart';
import 'package:capstone/features/public_user/pre_call_guidance/models/question_state.dart';
import 'package:capstone/features/public_user/reporting/providers/report_provider.dart';
import 'package:capstone/features/public_user/reporting/providers/report_repository_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final guidanceProvider = NotifierProvider<GuidanceNotifier, QuestionState>(
  GuidanceNotifier.new,
);

class GuidanceNotifier extends Notifier<QuestionState> {
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

  Future<void> submitGuidanceReport({required LatLng location}) async {
    final reportRepository = ref.read(reportRepositoryProvider);
    final userID = ref.read(firebaseAuthProvider).currentUser!.uid;

    final reportID = reportRepository.getReportID();
    final now = DateTime.now();

    final report = ref
        .read(reportProvider)
        .copyWith(
          reportID: reportID,
          referenceNumber: ReferenceNumberGenerator.generate(now),
          userID: userID,
          reportType: ReportTypeEnum.preCallGuidance,
          guidanceAnswers: state.questions,
          status: ReportStatusEnum.pending,
          location: GeoPoint(
            location.latitude,
            location.longitude,
          ),
          createdAt: now,
        );

    await ref.read(reportRepositoryProvider).createReport(report);
  }

  void loadQuestions(ServiceTypeEnum type) {
    switch (type) {
      case ServiceTypeEnum.medical:
        state = QuestionState(
          currentPage: 0,
          questions: [
            PreCallGuidanceModel(question: "Is the person conscious?"),
            PreCallGuidanceModel(question: "Is there life threatening injuries?"),
            PreCallGuidanceModel(question: "Is their current condition intentional?"),
          ],
        );
        break;

      case ServiceTypeEnum.police:
        state = QuestionState(
          currentPage: 0,
          questions: [
            PreCallGuidanceModel(question: "Is the suspect present?"),
            PreCallGuidanceModel(question: "Are there weapons involved?"),
            PreCallGuidanceModel(question: "Is someone injured?"),
          ],
        );
        break;

      case ServiceTypeEnum.fire:
        state = QuestionState(
          currentPage: 0,
          questions: [
            PreCallGuidanceModel(question: "Are there people trapped inside?"),
            PreCallGuidanceModel(question: "Is the fire spreading?"),
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
