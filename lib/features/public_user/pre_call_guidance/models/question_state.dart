import 'package:capstone/features/public_user/pre_call_guidance/models/pre_call_guidance_model.dart';

class QuestionState {
  final List<PreCallGuidanceModel> questions;
  final int currentPage;

  const QuestionState({
    required this.questions,
    this.currentPage = 0,
  });

  QuestionState copyWith({
    List<PreCallGuidanceModel>? questions,
    int? currentPage,
  }) {
    return QuestionState(
      questions: questions ?? this.questions,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
