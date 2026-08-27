class PreCallGuidanceModel {
  final String question;
  final bool? answer;

  PreCallGuidanceModel({
    required this.question,
    this.answer,
  });

  PreCallGuidanceModel copyWith({
    bool? answer,
  }) {
    return PreCallGuidanceModel(
      question: question,
      answer: answer,
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'answer': answer,
      };

  factory PreCallGuidanceModel.fromMap(Map<String, dynamic> map) {
    return PreCallGuidanceModel(
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
    );
  }
}
