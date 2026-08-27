class VictimModel {
  final String name;
  final String description;

  const VictimModel({
    this.name = '',
    this.description = '',
  });

  VictimModel copyWith({
    String? name,
    String? description,
  }) {
    return VictimModel(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }

  factory VictimModel.fromMap(Map<String, dynamic> map) {
    return VictimModel(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }
}
