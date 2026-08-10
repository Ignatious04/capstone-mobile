import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/deprecated/text_title_small.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/screen_title_text.dart';
import 'package:capstone/features/profile/views/personal_information_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  final double radius = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAuthenticatedUserProvider);
    return userAsync.when(
      data: (data) {
        if (data == null) {
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
                      child: Image.asset(
                        "assets/images/me.jpg",

                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ScreenTitleText(
                  value: "${data.firstName} ${data.lastName}",
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
                    value: "Personal Information",
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPressed: () {},
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
                            title: const TextTitleSmall(title: "Do you wish to log out?"),
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

                        await firebaseAuthRepository.signOut();
                      } on FirebaseAuthException catch (e) {
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
