import 'package:capstone/core/enums/guidance_type_enum.dart';
import 'package:capstone/features/pre_call_guidance/models/question_model.dart';
import 'package:capstone/core/states/question_state.dart';
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

  void loadQuestions(GuidanceTypeEnum type) {
    switch (type) {
      case GuidanceTypeEnum.medical:
        state = QuestionState(
          currentPage: 0,
          questions: [
            QuestionModel(question: "Is the person conscious?"),
            QuestionModel(question: "Is there life threatening injuries?"),
            QuestionModel(question: "Is their current condition intentional?"),
          ],
        );
        break;

      case GuidanceTypeEnum.police:
        state = QuestionState(
          currentPage: 0,
          questions: [
            QuestionModel(question: "Is the suspect present?"),
            QuestionModel(question: "Are there weapons involved?"),
            QuestionModel(question: "Is someone injured?"),
          ],
        );
        break;

      case GuidanceTypeEnum.fire:
        state = QuestionState(
          currentPage: 0,
          questions: [
            QuestionModel(question: "Are there people trapped inside?"),
            QuestionModel(question: "Is the fire spreading?"),
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
