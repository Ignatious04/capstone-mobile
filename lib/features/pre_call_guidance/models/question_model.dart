class QuestionModel {
  final String question;
  final bool? answer;

  QuestionModel({
    required this.question,
    this.answer,
  });

  QuestionModel copyWith({
    bool? answer,
  }) {
    return QuestionModel(
      question: question,
      answer: answer,
    );
  }
}
