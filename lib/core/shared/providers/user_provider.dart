import 'dart:io';
import 'package:capstone/core/shared/models/user_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_repository_provider.dart';
import 'package:capstone/features/reporting/providers/storage_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

final userProvider = NotifierProvider<UserNotifier, UserModel>(
  UserNotifier.new,
);

final currentAuthenticatedUserProvider = StreamProvider<UserModel?>((ref) {
  final currentUser = ref.watch(firebaseAuthProvider).currentUser;

  if (currentUser == null) {
    return Stream.value(null);
  }

  return ref
      .read(userRepositoryProvider)
      .watchUser(
        currentUser.uid,
      );
});

class UserNotifier extends Notifier<UserModel> {
  @override
  UserModel build() {
    return const UserModel();
  }

  void reset() {
    state = build();
  }

  Future<void> addProfilePicture(ImageSource source) async {
    final picker = ImagePicker();

    final image = await picker.pickImage(source: source);

    if (image == null) {
      return;
    }

    state = state.copyWith(
      profileImage: File(image.path),
    );
  }

  Future<void> updateUserSetup() async {
    setIsSetup(true);

    final userID = ref.read(firebaseAuthProvider).currentUser!.uid;
    var user = ref.read(userProvider);

    if (user.profileImage != null) {
      final fileName = path.basename(user.profileImage!.path);
      final profileURL = await ref
          .read(storageRepositoryProvider)
          .uploadProfilePicture(file: user.profileImage!, userID: userID, fileName: fileName);

      state = state.copyWith(profileURL: profileURL);
      user = ref.read(userProvider);
    }

    if (user.idImage != null) {
      final fileName = path.basename(user.idImage!.path);
      final idImageURL = await ref
          .read(storageRepositoryProvider)
          .uploadIdPicture(file: user.idImage!, userID: userID, fileName: fileName);

      state = state.copyWith(idImageURL: idImageURL);
      user = ref.read(userProvider);
    }

    await ref
        .read(userRepositoryProvider)
        .updateUser(
          userID,
          user.toMap(),
        );
  }

  void setUserID(String value) {
    state = state.copyWith(userID: value);
  }

  void removeProfilePicture(int index) {
    state = state.copyWith(profileImage: null);
  }

  void setIdImage(File value) {
    state = state.copyWith(idImage: value);
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
    state = state.copyWith(contactNumber: value);
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
    state = state.copyWith(idType: value);
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
}
