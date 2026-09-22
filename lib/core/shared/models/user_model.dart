import 'dart:io';

import 'package:capstone/core/enums/verification_status_enum.dart';

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
  final String vaccineDate;

  final int createdAt;
  final int updatedAt;
  final bool isSetup;
  final VerificationStatusEnum isVerified;

  final bool isDeactivated;
  final int? deactivatedAt;

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
    this.vaccineDate = "",
    this.createdAt = 0,
    this.updatedAt = 0,
    this.isSetup = false,
    this.isVerified = VerificationStatusEnum.pending,
    this.isDeactivated = false,
    this.deactivatedAt,
  });

  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      profileURL: map['profileURL'],
      firstName: map['firstName'] ?? '',
      middleName: map['middleName'] ?? '',
      lastName: map['lastName'] ?? '',
      birthDate: map['birthDate'] ?? 0,
      sex: map['sex'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      isContactNumberVerified: map["isContactNumberVerified"] ?? false,
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
      vaccineDate: map['vaccineDate'] ?? '',
      createdAt: map['createdAt'] ?? 0,
      updatedAt: map['updatedAt'] ?? 0,
      isSetup: map["isSetup"] ?? false,
      isVerified: VerificationStatusEnum.values.byName(map['isVerified'] ?? 'pending'),
      isDeactivated: map['isDeactivated'] ?? false,
      deactivatedAt: map['deactivatedAt'],
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
      'isVerified': isVerified.name,
      'isDeactivated': isDeactivated,
      'deactivatedAt': deactivatedAt,
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
    String? vaccineDate,
    int? createdAt,
    int? updatedAt,
    bool? isSetup,
    VerificationStatusEnum? isVerified,
    final bool? isDeactivated,
    final int? deactivatedAt,
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
      isVerified: isVerified ?? this.isVerified,
      isDeactivated: isDeactivated ?? this.isDeactivated,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }
}
