import 'package:capstone/core/enums/notification_type_enum.dart';

class NotificationModel {
  final String id;
  final NotificationTypeEnum type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? reportID;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.reportID,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      reportID: reportID,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'reportID': reportID,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      type: NotificationTypeEnum.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationTypeEnum.connectivity,
      ),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      isRead: map['isRead'] ?? false,
      reportID: map['reportID'],
    );
  }
}
