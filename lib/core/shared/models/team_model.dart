import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamModel {
  final String id;
  final String teamName;
  final ServiceTypeEnum department;
  final String serviceID;
  final String teamLeaderID;
  final List<String> memberIDs;
  final String createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeamModel({
    this.id = '',
    this.teamName = '',
    this.department = ServiceTypeEnum.medical,
    this.serviceID = '',
    this.teamLeaderID = '',
    this.memberIDs = const [],
    this.createdBy = '',
    this.createdAt,
    this.updatedAt,
  });

  int get memberCount => memberIDs.length;

  bool hasMember(String uid) => memberIDs.contains(uid);

  factory TeamModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return TeamModel(
      id: id,
      teamName: map['teamName'] ?? '',
      department: ServiceTypeEnum.values.firstWhere(
        (e) => e.name == map['department'],
        orElse: () => ServiceTypeEnum.medical,
      ),
      serviceID: map['serviceID'] ?? '',
      teamLeaderID: map['teamLeaderID'] ?? '',
      memberIDs: List<String>.from(map['memberIDs'] ?? const []),
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}