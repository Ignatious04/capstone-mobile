import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/shared/widgets/emergency_guidance_sheet.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/pre_call_guidance/providers/guidance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows the SMS report before it's handed to the native messaging app, then
/// asks whether it was sent once the user returns. Pops with `true` once the
/// user confirms, `false` if they cancel.
class SmsReviewScreen extends ConsumerStatefulWidget {
  const SmsReviewScreen({super.key});

  @override
  ConsumerState<SmsReviewScreen> createState() => _SmsReviewScreenState();
}

class _SmsReviewScreenState extends ConsumerState<SmsReviewScreen> with WidgetsBindingObserver {
  bool _opened = false; // "Open Messages" was tapped
  bool _wentAway = false; // the app actually left the foreground afterwards
  bool _returned = false; // ...and came back, so ask whether it was sent

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_opened) return;
    if (state != AppLifecycleState.resumed) {
      _wentAway = true;
    } else if (_wentAway && !_returned) {
      setState(() => _returned = true);
    }
  }

  Future<void> _openMessages() async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(guidanceProvider.notifier);
    final number = notifier.smsDraft?.number ?? '';

    setState(() {
      _opened = true;
      _wentAway = false;
      _returned = false;
    });

    try {
      await notifier.openSmsDraft();
    } catch (e) {
      debugPrint('ERROR: $e');
      if (!mounted) return;
      setState(() => _opened = false);
      CustomSnackbarHelper.show(context, text: l10n.smsLaunchError(number));
    }
  }

  Future<void> _confirmSent() async {
    final draft = ref.read(guidanceProvider.notifier).smsDraft;
    if (draft != null) {
      await EmergencyGuidanceSheet.show(context, draft.incidentType, dismissible: false);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final draft = ref.read(guidanceProvider.notifier).smsDraft;

    if (draft == null) {
      return Scaffold(appBar: CustomAppBar(value: l10n.smsReviewTitle));
    }

    return PopScope(
      // Free to back out before Messages is opened; after that the user has to
      // answer below, so a back gesture can't lead to a duplicate submission.
      canPop: !_opened,
      child: Scaffold(
        appBar: CustomAppBar(value: l10n.smsReviewTitle),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: AppColors.bgWhiteLight,
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.sms, color: AppColors.themeColor, size: 50),
                        const SizedBox(height: 10),
                        BodyText(
                          value: l10n.smsReviewIntro,
                          alignment: TextAlign.center,
                          isOverflow: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: AppColors.bgWhiteLight,
                  elevation: 1,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelText(value: l10n.smsReviewRecipient(draft.number), isBold: true),
                        const Divider(height: 20),
                        BodyText(value: draft.body, isOverflow: false),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!_returned)
                  CustomElevatedButton(
                    onPressed: _openMessages,
                    value: l10n.openMessagesButton.toUpperCase(),
                    icon: const Icon(Icons.sms),
                    color: AppColors.whiteTextFull,
                    backgroundColor: AppColors.themeColor,
                  )
                else ...[
                  TitleText(value: l10n.smsSentQuestion, alignment: TextAlign.center),
                  const SizedBox(height: 10),
                  CustomElevatedButton(
                    onPressed: _confirmSent,
                    value: l10n.smsSentConfirm,
                    icon: const Icon(Icons.check_circle),
                    color: AppColors.whiteTextFull,
                    backgroundColor: AppColors.darkerGreen,
                  ),
                  CustomElevatedButton(
                    onPressed: _openMessages,
                    value: l10n.smsNotSentYet,
                    icon: const Icon(Icons.sms),
                    color: AppColors.whiteTextFull,
                    backgroundColor: AppColors.themeColor,
                  ),
                  CustomElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    value: l10n.cancel,
                    color: AppColors.whiteTextFull,
                    backgroundColor: AppColors.blackTextMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}