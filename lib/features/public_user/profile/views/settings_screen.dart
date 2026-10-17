import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/features/public_user/profile/views/change_password_screen.dart';
import 'package:capstone/features/public_user/profile/views/deactivate_account_screen.dart';
import 'package:capstone/features/public_user/profile/views/phone_number_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAuthenticatedUserProvider).value;
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(value: l10n.settings),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleText(
                  value: l10n.general,
                  isBold: false,
                ),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.all(0),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.black12,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.language,
                      size: 25,
                    ),
                    title: BodyText(
                      value: l10n.language,
                    ),
                    subtitle: BodyText(
                      value: locale.languageCode == 'en' ? 'English' : 'Filipino',
                      isBold: true,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            backgroundColor: Colors.white,
                            title: TitleText(
                              value: l10n.selectLanguage,
                              isBold: false,
                            ),
                            children: [
                              SimpleDialogOption(
                                onPressed: () {
                                  ref.read(localeProvider.notifier).state = const Locale('en');

                                  Navigator.pop(context);
                                },
                                child: const BodyText(
                                  value: 'English',
                                  isBold: true,
                                ),
                              ),
                              SimpleDialogOption(
                                onPressed: () {
                                  ref.read(localeProvider.notifier).state = const Locale('fil');

                                  Navigator.pop(context);
                                },
                                child: const BodyText(
                                  value: 'Filipino',
                                  isBold: true,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                TitleText(
                  value: l10n.security,
                  isBold: false,
                ),
                if (user != null && !user.isContactNumberVerified) ...[
                  const SizedBox(height: 10),
                  Card(
                    margin: EdgeInsets.all(0),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.black12,
                      ),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.phone_android),
                      title: TitleText(value: l10n.verifyPhoneNumber),
                      subtitle: BodyText(value: l10n.verifyPhoneRequired),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhoneNumberVerificationScreen(currentContactNumber: user.contactNumber),
                        ),
                      ),
                    ),
                  ),
                ],
                if (ref.read(firebaseAuthRepositoryProvider).hasPasswordProvider) ...[
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text(l10n.changePassword),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
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
                    value: l10n.deactivateAccount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
