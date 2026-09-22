import 'package:cached_network_image/cached_network_image.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/data_label_text.dart';
import 'package:capstone/core/shared/widgets/text/data_value_text.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/text/section_title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/profile/views/deactivate_account_screen.dart';
import 'package:capstone/features/public_user/profile/views/update_personal_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PersonalInformationScreen extends ConsumerWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentAuthenticatedUserProvider);
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text("User not found"),
            ),
          );
        }
        return Scaffold(
          appBar: CustomAppBar(value: "Safety Profile"),
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
                          SectionTitleText(
                            value: "${user.firstName} ${user.lastName}",
                            isBold: true,
                          ),
                          SectionTitleText(
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
                                const DataLabelText(
                                  value: "DATE OF BIRTH",
                                ),
                                DataValueText(
                                  value: DateFormat("MMMM dd, yyyy").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      user.birthDate,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const DataLabelText(
                                  value: "SEX",
                                ),
                                DataValueText(
                                  value: user.sex,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const DataLabelText(
                                  value: "HOME ADDRESS",
                                ),
                                DataValueText(
                                  value: user.address,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const DataLabelText(
                                  value: "NATIONALITY",
                                ),
                                DataValueText(
                                  value: user.nationality,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const DataLabelText(
                                  value: "Civil Status",
                                ),
                                DataValueText(
                                  value: user.civilStatus,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const DataLabelText(
                                  value: "Religion",
                                ),
                                DataValueText(
                                  value: user.religion,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.black,
                                ),
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
                              value: "Update Personal Information",
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: CustomElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const DeactivateAccountScreen()),
                                );
                              },
                              color: Colors.red,
                              backgroundColor: Colors.white,
                              value: "Deactivate Account",
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
