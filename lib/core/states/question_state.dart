import 'package:capstone/features/pre_call_guidance/models/question_model.dart';

class QuestionState {
  final List<QuestionModel> questions;
  final int currentPage;

  const QuestionState({
    required this.questions,
    this.currentPage = 0,
  });

  QuestionState copyWith({
    List<QuestionModel>? questions,
    int? currentPage,
  }) {
    return QuestionState(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
