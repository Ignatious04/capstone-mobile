import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone/core/exceptions/auth_exception.dart';
import 'package:capstone/core/services/push_notification_service.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/headline_text.dart';
import 'package:capstone/core/shared/widgets/view_attachment_screen.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/profile/views/medical_information_screen.dart';
import 'package:capstone/features/public_user/profile/views/personal_information_screen.dart';
import 'package:capstone/features/public_user/profile/views/settings_screen.dart';
import 'package:capstone/features/public_user/profile/widgets/replace_profile_photo_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  final double radius = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.of(context).size.width;

    final userAsync = ref.watch(currentAuthenticatedUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Center(
            child: CustomCircularProgressIndicator(),
          );
        }
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: CustomHeaderWidget(title: l10n.safetyProfile, body: l10n.viewManageAccount),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        elevation: 0,
                        color: AppColors.bgWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: AppColors.cardBorder,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 90, left: 20, right: 20, bottom: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ReplaceProfilePhotoButton(currentUrl: user.profileURL),
                              const SizedBox(
                                height: 10,
                              ),
                              HeadlineText(
                                value: "${user.firstName} ${user.lastName}",
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
                                  icon: Icon(
                                    Icons.person,
                                    size: 25,
                                    color: AppColors.themeColor,
                                  ),
                                  backgroundColor: AppColors.bgWhiteLight,
                                  color: AppColors.blackTextFull,
                                  borderRadius: 24,
                                  value: l10n.personalInformation,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: CustomElevatedButton(
                                  onPressed: () {
                                    if (!user.canEditMedicalInfo) {
                                      CustomSnackbarHelper.show(context, text: l10n.medicalInfoNeedsConsent);
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => MedicalInformationScreen(user: user)),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.medical_information,
                                    size: 25,
                                    color: AppColors.themeColor,
                                  ),
                                  backgroundColor: AppColors.bgWhiteLight,
                                  color: AppColors.blackTextFull,
                                  borderRadius: 24,
                                  value: l10n.medicalInformation,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
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
                                  icon: Icon(
                                    Icons.settings,
                                    size: 25,
                                    color: AppColors.themeColor,
                                  ),
                                  backgroundColor: AppColors.bgWhiteLight,
                                  color: AppColors.blackTextFull,
                                  borderRadius: 24,
                                  value: l10n.settings,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: CustomElevatedButton(
                                  onPressed: () async {
                                    final dialog = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: BodyText(value: l10n.logoutConfirm),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          backgroundColor: AppColors.bgWhite,
                                          actions: [
                                            CustomElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              value: l10n.no,
                                              backgroundColor: AppColors.bgWhiteLight,
                                              color: AppColors.blackTextFull,
                                            ),
                                            CustomElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              value: l10n.yes,
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
                                  icon: Icon(
                                    Icons.logout,
                                    size: 25,
                                  ),
                                  color: AppColors.danger,
                                  backgroundColor: AppColors.bgWhiteLight,
                                  borderColor: AppColors.danger.withValues(alpha: 0.5),
                                  borderRadius: 24,
                                  value: l10n.logout,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: -75,
                        left: (screenWidth / 2) - 100,
                        child: Hero(
                          tag: "profile_pic",
                          child: GestureDetector(
                            onTap: user.profileURL == null
                                ? null
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewAttachmentScreen(
                                        fileName: l10n.profilePhoto,
                                        url: user.profileURL!,
                                      ),
                                    ),
                                  ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3), // Shadow color and opacity
                                    spreadRadius: 1,
                                    blurRadius: 5, // Softness of the shadow
                                    offset: const Offset(0, 5), // Changes position of shadow (x, y)
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: user.profileURL != null
                                    ? CachedNetworkImage(
                                        imageUrl: user.profileURL!,
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, _, _) => Container(
                                          width: 150,
                                          height: 150,
                                          color: AppColors.lighterBlack,
                                          child: const Icon(Icons.person, size: 50),
                                        ),
                                      )
                                    : Container(
                                        color: AppColors.lighterBlack,
                                        child: const Icon(Icons.person, size: 50),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
