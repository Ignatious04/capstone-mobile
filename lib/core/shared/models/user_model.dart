import 'dart:io';
import 'package:capstone/core/enums/consent_status_enum.dart';
import 'package:capstone/core/enums/guardian_relationship_enum.dart';
import 'package:capstone/core/enums/rejection_code_enum.dart';
import 'package:capstone/core/enums/verification_status_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

int? _toMillis(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is Timestamp) return v.millisecondsSinceEpoch;
  if (v is DateTime) return v.millisecondsSinceEpoch;
  return null;
}

class UserModel {
  final String userID;
  final File? profileImage;
  final String? profileURL;
  final String firstName;
  final String middleName;
  final String lastName;
  final int birthDate;
  final String sex;
  final String contactNumber;
  final bool isContactNumberVerified;

  final String houseNum;
  final String street;
  final String barangay;

  final String address;
  final String nationality;
  final String civilStatus;
  final String religion;
  final String idType;
  final File? idImage;
  final String? idImageURL;
  final String idNumber;

  final String email;

  final String bloodType;
  final double height;
  final double weight;
  final bool isVaccinated;
  final String vaccineType;
  final int vaccineDate;

  final int createdAt;
  final int updatedAt;
  final bool isSetup;
  final VerificationStatusEnum verificationStatus;

  final RejectionCodeEnum? rejectionCode;
  final String? rejectionReason;
  final bool canResubmit;
  final int? reviewedAt;
  final String? reviewedBy;
  final int? verificationSubmittedAt;

  final bool isDeactivated;
  final int? deactivatedAt;

  final int resubmissionCount;

  final String guardianName;
  final GuardianRelationshipEnum? guardianRelationship;
  final String guardianContact;
  final ConsentStatusEnum consentStatus;
  final int? consentLastSentAt;
  final int consentSendCount;

  const UserModel({
    this.userID = "",
    this.profileImage,
    this.profileURL,
    this.firstName = "",
    this.middleName = "",
    this.lastName = "",
    this.birthDate = 0,
    this.sex = "",
    this.contactNumber = "",
    this.isContactNumberVerified = false,
    this.houseNum = "",
    this.street = "",
    this.barangay = "",
    this.address = "",
    this.nationality = "",
    this.civilStatus = "",
    this.religion = "",
    this.idType = "",
    this.idImage,
    this.idImageURL,
    this.idNumber = "",
    this.email = "",
    this.bloodType = "",
    this.height = 0,
    this.weight = 0,
    this.isVaccinated = false,
    this.vaccineType = "",
    this.vaccineDate = 0,
    this.createdAt = 0,
    this.updatedAt = 0,
    this.isSetup = false,
    this.verificationStatus = VerificationStatusEnum.pending,
    this.rejectionCode,
    this.rejectionReason,
    this.canResubmit = true,
    this.reviewedAt,
    this.reviewedBy,
    this.verificationSubmittedAt,
    this.isDeactivated = false,
    this.deactivatedAt,
    this.resubmissionCount = 0,
    this.guardianName = "",
    this.guardianRelationship,
    this.guardianContact = "",
    this.consentStatus = ConsentStatusEnum.notRequired,
    this.consentLastSentAt,
    this.consentSendCount = 0,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      profileURL: map['profileURL'],
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      birthDate: _toMillis(map['birthDate']) ?? 0,
      sex: map['sex'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      isContactNumberVerified: map["isContactNumberVerified"] ?? false,
      houseNum: map['houseNum'] ?? '',
      street: map['street'] ?? '',
      barangay: map['barangay'] ?? '',
      address: map['address'] ?? '',
      nationality: map['nationality'] ?? '',
      civilStatus: map['civilStatus'] ?? '',
      religion: map['religion'] ?? '',
      idType: map['idType'] ?? '',
      idImageURL: map['idImageURL'],
      idNumber: map["idNumber"] ?? "",
      email: map['email'] ?? '',
      bloodType: map['bloodType'] ?? '',
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      weight: (map['weight'] as num?)?.toDouble() ?? 0.0,
      isVaccinated: map['isVaccinated'] ?? false,
      vaccineType: map['vaccineType'] ?? '',
      vaccineDate: _toMillis(map['vaccineDate']) ?? 0,
      createdAt: _toMillis(map['createdAt']) ?? 0,
      updatedAt: _toMillis(map['updatedAt']) ?? 0,
      isSetup: map["isSetup"] ?? false,
      verificationStatus:
          VerificationStatusEnum.values.asNameMap()[map['verificationStatus']] ?? VerificationStatusEnum.pending,
      rejectionCode: RejectionCodeEnum.tryParse(map['rejectionCode']),
      rejectionReason: map['rejectionReason'],
      canResubmit: map['canResubmit'] ?? true,
      reviewedAt: _toMillis(map['reviewedAt']),
      reviewedBy: map['reviewedBy'],
      verificationSubmittedAt: _toMillis(map['verificationSubmittedAt']),
      isDeactivated: map['isDeactivated'] ?? false,
      deactivatedAt: _toMillis(map['deactivatedAt']),
      resubmissionCount: map['resubmissionCount'] ?? 0,
      guardianName: map['guardianName'] ?? '',
      guardianRelationship: GuardianRelationshipEnum.tryParse(map['guardianRelationship']),
      guardianContact: map['guardianContact'] ?? '',
      consentStatus: ConsentStatusEnum.values.asNameMap()[map['consentStatus']] ?? ConsentStatusEnum.notRequired,
      consentLastSentAt: _toMillis(map['consentLastSentAt']),
      consentSendCount: map['consentSendCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'profileURL': profileURL,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'birthDate': birthDate,
      'sex': sex,
      'contactNumber': contactNumber,
      "isContactNumberVerified": isContactNumberVerified,
      'houseNum': houseNum,
      'street': street,
      'barangay': barangay,
      'address': address,
      'nationality': nationality,
      'civilStatus': civilStatus,
      'religion': religion,
      'idType': idType,
      'idImageURL': idImageURL,
      'idNumber': idNumber,
      'email': email,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'isVaccinated': isVaccinated,
      'vaccineType': vaccineType,
      'vaccineDate': vaccineDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSetup': isSetup,
      'verificationStatus': verificationStatus.name,
      'isDeactivated': isDeactivated,
      'deactivatedAt': deactivatedAt,
      'guardianName': guardianName,
      'guardianRelationship': guardianRelationship?.name,
      'guardianContact': guardianContact,
    };
  }

  UserModel copyWith({
    String? userID,
    File? profileImage,
    bool clearProfileImage = false,
    String? profileURL,
    String? firstName,
    String? middleName,
    String? lastName,
    int? birthDate,
    String? sex,
    String? contactNumber,
    bool? isContactNumberVerified,
    String? houseNum,
    String? street,
    String? barangay,
    String? address,
    String? nationality,
    String? civilStatus,
    String? religion,
    String? idType,
    bool clearIdImage = false,
    File? idImage,
    String? idImageURL,
    String? idNumber,
    String? email,
    String? bloodType,
    double? height,
    double? weight,
    bool? isVaccinated,
    String? vaccineType,
    int? vaccineDate,
    int? createdAt,
    int? updatedAt,
    bool? isSetup,
    VerificationStatusEnum? verificationStatus,
    final bool? isDeactivated,
    final int? deactivatedAt,
    final int? verificationSubmittedAt,
    final String? guardianName,
    GuardianRelationshipEnum? guardianRelationship,
    final String? guardianContact,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      profileImage: clearProfileImage ? null : (profileImage ?? this.profileImage),
      profileURL: profileURL ?? this.profileURL,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      contactNumber: contactNumber ?? this.contactNumber,
      isContactNumberVerified: isContactNumberVerified ?? this.isContactNumberVerified,
      houseNum: houseNum ?? this.houseNum,
      street: street ?? this.street,
      barangay: barangay ?? this.barangay,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      civilStatus: civilStatus ?? this.civilStatus,
      religion: religion ?? this.religion,
      idType: idType ?? this.idType,
      idImage: clearIdImage ? null : (idImage ?? this.idImage),
      idImageURL: idImageURL ?? this.idImageURL,
      idNumber: idNumber ?? this.idNumber,
      email: email ?? this.email,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      vaccineType: vaccineType ?? this.vaccineType,
      vaccineDate: vaccineDate ?? this.vaccineDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSetup: isSetup ?? this.isSetup,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionCode: rejectionCode,
      rejectionReason: rejectionReason,
      canResubmit: canResubmit,
      reviewedAt: reviewedAt,
      reviewedBy: reviewedBy,
      isDeactivated: isDeactivated ?? this.isDeactivated,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
      verificationSubmittedAt: verificationSubmittedAt ?? this.verificationSubmittedAt,
      resubmissionCount: resubmissionCount,
      guardianName: guardianName ?? this.guardianName,
      guardianRelationship: guardianRelationship ?? this.guardianRelationship,
      guardianContact: guardianContact ?? this.guardianContact,
      consentStatus: consentStatus,
      consentLastSentAt: consentLastSentAt,
      consentSendCount: consentSendCount,
    );
  }

  bool get isMinor {
    if (birthDate == 0) return false;
    final dob = DateTime.fromMillisecondsSinceEpoch(birthDate);
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age < 18;
  }
}
