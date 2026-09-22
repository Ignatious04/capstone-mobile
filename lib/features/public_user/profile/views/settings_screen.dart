import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:capstone/features/public_user/profile/views/change_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  locale.languageCode == 'en' ? 'English' : 'Filipino',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SimpleDialog(
                        title: const Text('Select Language'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () {
                              ref.read(localeProvider.notifier).state = const Locale('en');

                              Navigator.pop(context);
                            },
                            child: const Text('English'),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              ref.read(localeProvider.notifier).state = const Locale('fil');

                              Navigator.pop(context);
                            },
                            child: const Text('Filipino'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Divider(),
              if (ref.read(firebaseAuthRepositoryProvider).hasPasswordProvider)
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
