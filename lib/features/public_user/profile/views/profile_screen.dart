import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:capstone/core/shared/widgets/text/supporting_info_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/profile/views/personal_information_screen.dart';
import 'package:capstone/features/public_user/profile/views/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  final double radius = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAuthenticatedUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(
            child: CustomCircularProgressIndicator(),
          );
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: "profile_pic",
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: ClipOval(
                      child: user.profileURL != null
                          ? CachedNetworkImage(
                              imageUrl: user.profileURL!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppColors.lighterBlack,
                              child: const Icon(Icons.person, size: 50),
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ScreenTitleText(
                  value: "${user.firstName} ${user.lastName}",
                  isBold: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PersonalInformationScreen();
                          },
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    color: Colors.black,
                    value: "Personal Information",
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SettingsScreen();
                          },
                        ),
                      );
                    },
                    backgroundColor: Colors.white,
                    color: Colors.black,
                    value: "Settings",
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPressed: () async {
                      final dialog = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const SupportingInfoText(value: "Do you wish to log out?"),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.white,
                            actions: [
                              CustomElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                value: "No",
                              ),
                              CustomElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                value: "Yes",
                              ),
                            ],
                          );
                        },
                      );

                      if (dialog != true) {
                        return;
                      }

                      try {
                        final firebaseAuthRepository = ref.read(
                          firebaseAuthRepositoryProvider,
                        );

                        final uid = firebaseAuthRepository.currentUser?.uid;

                        if (uid != null) {
                          await ref.read(pushNotificationServiceProvider).clearToken(uid);
                        }
                        await firebaseAuthRepository.signOut();
                      } on AuthException catch (e) {
                        debugPrint(e.message);
                      }
                    },
                    color: Colors.red,
                    backgroundColor: Colors.white,
                    value: "Log Out",
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(body: Center(child: Text(error.toString()))),
      loading: () => Scaffold(
        body: const Center(
          child: CustomCircularProgressIndicator(),
        ),
      ),
    );
  }
}
