import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/shared/widgets/view_attachment_screen.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/profile/views/update_personal_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final userAsync = ref.watch(currentAuthenticatedUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Text(l10n.userNotFound),
            ),
          );
        }
        return Scaffold(
          appBar: CustomAppBar(value: l10n.safetyProfile),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Hero(
                            tag: "profile_pic",
                            child: SizedBox(
                              width: 150,
                              height: 150,
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
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TitleText(
                            value: "${user.firstName} ${user.lastName}",
                            isBold: true,
                          ),
                          BodyText(
                            value: user.contactNumber,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabelText(
                                  value: l10n.birthDate.toUpperCase(),
                                  color: Colors.black54,
                                ),
                                BodyText(
                                  value: DateFormat("MMMM dd, yyyy", Localizations.localeOf(context).toString()).format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      user.birthDate,
                                    ),
                                  ),
                                  isBold: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                LabelText(
                                  value: l10n.sex.toUpperCase(),
                                  color: Colors.black54,
                                ),
                                BodyText(
                                  value: user.sex,
                                  isBold: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                LabelText(
                                  value: l10n.homeAddress.toUpperCase(),
                                  color: Colors.black54,
                                ),
                                BodyText(
                                  value: user.address,
                                  isBold: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                LabelText(
                                  value: l10n.nationality.toUpperCase(),
                                  color: Colors.black54,
                                ),
                                BodyText(
                                  value: user.nationality,
                                  isBold: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                LabelText(
                                  value: l10n.civilStatus.toUpperCase(),
                                  color: Colors.black54,
                                ),
                                BodyText(
                                  value: user.civilStatus,
                                  isBold: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                LabelText(
                                  value: l10n.religion.toUpperCase(),
                                  color: Colors.black54,
                                ),
                                BodyText(
                                  value: user.religion,
                                  isBold: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: CustomElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return UpdatePersonalInformationScreen(
                                        user: user,
                                      );
                                    },
                                  ),
                                );
                              },
                              value: l10n.updatePersonalInformation,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) => Scaffold(body: Center(child: Text(error.toString()))),
      loading: () => const Scaffold(
        body: Center(
          child: CustomCircularProgressIndicator(),
        ),
      ),
    );
  }
}
