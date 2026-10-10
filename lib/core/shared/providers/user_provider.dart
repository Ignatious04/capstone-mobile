import 'dart:io';
import 'package:capstone/core/enums/facecheck_result_enum.dart';
import 'package:capstone/core/enums/id_capture_result_enum.dart';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/core/shared/providers/storage_repository_provider.dart';
import 'package:capstone/features/public_user/setup/providers/face_detection_service_provider.dart';
import 'package:capstone/features/public_user/setup/providers/ocr_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

final userProvider = NotifierProvider<UserNotifier, UserModel>(
  UserNotifier.new,
);

final currentAuthenticatedUserProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authStateProvider).value;

  if (authUser == null) {
    return Stream.value(null);
  }

  return ref.read(userRepositoryProvider).watchUser(authUser.uid);
});

class UserNotifier extends Notifier<UserModel> {
  @override
  UserModel build() {
    return const UserModel();
  }

  void reset() {
    state = build();
  }

  Future<String?> addProfilePicture(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image == null) {
      return null;
    }

    final faceCheck = await ref.read(faceDetectionServiceProvider).checkFace(image.path);

    if (faceCheck != FaceCheckResult.ok) {
      return faceCheck.message;
    }

    state = state.copyWith(profileImage: File(image.path));
    return null;
  }

  Future<void> updateUserSetup() async {
    final authUser = ref.read(firebaseAuthProvider).currentUser!;
    final userID = authUser.uid;
    var user = state;

    if (user.profileImage != null) {
      final fileName = path.basename(user.profileImage!.path);
      final profileURL = await ref
          .read(storageRepositoryProvider)
          .uploadProfilePicture(file: user.profileImage!, userID: userID, fileName: fileName);

      state = state.copyWith(profileURL: profileURL);
      user = state;
    }

    if (user.idImage != null) {
      final fileName = path.basename(user.idImage!.path);
      final idImageURL = await ref
          .read(storageRepositoryProvider)
          .uploadIdPicture(file: user.idImage!, userID: userID, fileName: fileName);

      state = state.copyWith(idImageURL: idImageURL);
      user = state;
    }

    setIsSetup(true);

    user = state.copyWith(
      userID: userID,
      email: authUser.email ?? state.email,
      address: "${user.houseNum}, ${user.street}, ${user.barangay}",
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final data = user.toMap();
    if (user.createdAt == 0) data.remove('createdAt'); // keep the original from registration

    await ref
        .read(userRepositoryProvider)
        .updateUser(
          userID,
          data,
        );
  }

  Future<String?> captureId(File file) async {
    final idNumber = await ref.read(ocrServiceProvider).extractIdNumber(file.path, state.idType);

    if (idNumber == null) {
      return IdCaptureResult.unreadable.message;
    }

    final userID = ref.read(firebaseAuthProvider).currentUser!.uid;
    final isDuplicate = await ref.read(userRepositoryProvider).isIdNumberTaken(idNumber, excludeUserID: userID);

    if (isDuplicate) {
      return IdCaptureResult.duplicate.message;
    }

    state = state.copyWith(idImage: file, idNumber: idNumber);
    return null;
  }

  void prefillFromGoogle({String? givenName, String? familyName, String? displayName}) {
    var first = givenName?.trim() ?? '';
    var last = familyName?.trim() ?? '';

    // Fallback if Google didn't send the separate parts.
    if (first.isEmpty && last.isEmpty && displayName != null && displayName.trim().isNotEmpty) {
      final parts = displayName.trim().split(RegExp(r'\s+'));
      last = parts.length > 1 ? parts.removeLast() : '';
      first = parts.join(' ');
    }

    state = state.copyWith(
      firstName: state.firstName.isEmpty ? first : state.firstName,
      lastName: state.lastName.isEmpty ? last : state.lastName,
    );
  }

  bool syncVerifiedPhone() {
    final verified = ref.read(firebaseAuthRepositoryProvider).verifiedPhoneNumber;
    if (verified == null || verified.isEmpty) return false;
    setContactNumber(verified);
    setIsContactNumberVerified(true);
    return true;
  }

  void setUserID(String value) {
    state = state.copyWith(userID: value);
  }

  void removeProfilePicture(int index) {
    state = state.copyWith(clearProfileImage: true);
  }

  void setIdImage(File value) {
    state = state.copyWith(idImage: value);
  }

  void setIdNumber(String value) {
    state = state.copyWith(idNumber: value);
  }

  void setProfileURL(String url) {
    state = state.copyWith(profileURL: url);
  }

  void setFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void setMiddleName(String value) {
    state = state.copyWith(middleName: value);
  }

  void setLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void setBirthDate(int value) {
    state = state.copyWith(birthDate: value);
  }

  void setSex(String value) {
    state = state.copyWith(sex: value);
  }

  void setContactNumber(String value) {
    final digits = value.replaceFirst(RegExp(r'^\+63'), '');
    state = state.copyWith(
      contactNumber: "+63$digits",
    );
  }

  void setIsContactNumberVerified(bool value) {
    state = state.copyWith(isContactNumberVerified: value);
  }

  void setHouseNum(String value) {
    state = state.copyWith(houseNum: value);
  }

  void setStreet(String value) {
    state = state.copyWith(street: value);
  }

  void setBarangay(String value) {
    state = state.copyWith(barangay: value);
  }

  void setAddress(String value) {
    state = state.copyWith(address: value);
  }

  void setNationality(String value) {
    state = state.copyWith(nationality: value);
  }

  void setCivilStatus(String value) {
    state = state.copyWith(civilStatus: value);
  }

  void setReligion(String value) {
    state = state.copyWith(religion: value);
  }

  void setIDType(String value) {
    if (value == state.idType) return;
    state = state.copyWith(idType: value, clearIdImage: true, idNumber: '');
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setBloodType(String value) {
    state = state.copyWith(bloodType: value);
  }

  void setHeight(double value) {
    state = state.copyWith(height: value);
  }

  void setWeight(double value) {
    state = state.copyWith(weight: value);
  }

  void setIsVaccinated(bool value) {
    state = state.copyWith(isVaccinated: value);
  }

  void setVaccineType(String value) {
    state = state.copyWith(vaccineType: value);
  }

  void setVaccineDate(String value) {
    state = state.copyWith(vaccineDate: value);
  }

  void setIsSetup(bool value) {
    state = state.copyWith(isSetup: value);
  }

  void setCreatedAt(int value) {
    state = state.copyWith(createdAt: value);
  }

  void setUpdatedAt(int value) {
    state = state.copyWith(updatedAt: value);
  }
}
