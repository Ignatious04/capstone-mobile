import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/text/text_body_medium.dart';
import 'package:capstone/core/shared/widgets/text/text_body_small.dart';
import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/features/profile/views/update_personal_information_screen.dart';
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
          appBar: AppBar(
            toolbarHeight: 40,
            title: Column(
              children: [
                const TextTitleSmall(
                  title: "Back",
                  color: Colors.white,
                ),
              ],
            ),
            titleSpacing: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                  child: CustomHeaderWidget(
                    title: "Safety Profile",
                    body: "View your information",
                  ),
                ),
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
                          TextTitleSmall(
                            title: "${user.firstName} ${user.lastName}",
                            isBold: true,
                          ),
                          TextTitleSmall(
                            title: user.contactNumber,
                            isBold: true,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextBodySmall(
                                  title: "Date of Birth",
                                ),
                                TextBodyMedium(
                                  title: DateFormat("MMMM dd, yyyy").format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      user.birthDate,
                                    ),
                                  ),
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const TextBodySmall(
                                  title: "Sex",
                                ),
                                TextBodyMedium(
                                  title: user.sex,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const TextBodySmall(
                                  title: "Home Address",
                                ),
                                TextBodyMedium(
                                  title: user.address,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const TextBodySmall(
                                  title: "Nationality",
                                ),
                                TextBodyMedium(
                                  title: user.nationality,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const TextBodySmall(
                                  title: "Civil Status",
                                ),
                                TextBodyMedium(
                                  title: user.civilStatus,
                                  color: Colors.black,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const TextBodySmall(
                                  title: "Religion",
                                ),
                                TextBodyMedium(
                                  title: user.religion,
                                  color: Colors.black,
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return UpdatePersonalInformationScreen(user: user,);
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Update Personal Information"),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Deactivate Account",
                                style: TextStyle(color: Colors.red),
                              ),
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
