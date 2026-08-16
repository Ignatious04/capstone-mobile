import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/features/pre_call_guidance/models/pre_call_guidance_model.dart';
import 'package:capstone/features/pre_call_guidance/models/question_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
