class PreCallGuidanceModel {
  final String id;
  final String question;
  final bool? answer;

  PreCallGuidanceModel({
    required this.id,
    required this.question,
    this.answer,
  });

  PreCallGuidanceModel copyWith({
    bool? answer,
  }) {
    return PreCallGuidanceModel(
      id: id,
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
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] as bool?,
    );
  }
}
