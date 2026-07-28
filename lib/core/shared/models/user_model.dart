import 'dart:io';

class UserModel {
  final String userID;
  final String? profileURL;
  final String firstName;
  final String middleName;
  final String lastName;
  final int birthDate;
  final String sex;
  final String contactNumber;
  final String address;
  final String nationality;
  final String civilStatus;
  final String religion;
  final String idType;

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
  final bool isVerified;

  const UserModel({
    this.userID = "",
    this.profileURL,
    this.firstName = "",
    this.middleName = "",
    this.lastName = "",
    this.birthDate = 0,
    this.sex = "",
    this.contactNumber = "",
    this.address = "",
    this.nationality = "",
    this.civilStatus = "",
    this.religion = "",
    this.idType = "",
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
    this.isVerified = false,
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
      address: map['address'] ?? '',
      nationality: map['nationality'] ?? '',
      civilStatus: map['civilStatus'] ?? '',
      religion: map['religion'] ?? '',
      idType: map['idType'] ?? '',
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
      isVerified: map['isVerified'] ?? false,
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
      'address': address,
      'nationality': nationality,
      'civilStatus': civilStatus,
      'religion': religion,
      'idType': idType,
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
      'isVerified': isVerified,
    };
  }

  UserModel copyWith({
    String? userID,
    File? profileImage,
    String? profileURL,
    String? firstName,
    String? middleName,
    String? lastName,
    int? birthDate,
    String? sex,
    String? contactNumber,
    String? address,
    String? nationality,
    String? civilStatus,
    String? religion,
    String? idType,
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
    bool? isVerified,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      profileURL: profileURL ?? this.profileURL,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      contactNumber: contactNumber ?? this.contactNumber,
      address: address ?? this.address,
      nationality: nationality ?? this.nationality,
      civilStatus: civilStatus ?? this.civilStatus,
      religion: religion ?? this.religion,
      idType: idType ?? this.idType,
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
    );
  }
}
