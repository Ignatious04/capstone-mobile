import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/user_provider.dart';
import 'package:capstone/core/shared/providers/verification_provider.dart';
import 'package:capstone/core/shared/widgets/custom_snackbar_helper.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplaceProfilePhotoButton extends ConsumerStatefulWidget {
  const ReplaceProfilePhotoButton({super.key, required this.currentUrl});

  final String? currentUrl;

  @override
  ConsumerState<ReplaceProfilePhotoButton> createState() => _ReplaceProfilePhotoButtonState();
}

class _ReplaceProfilePhotoButtonState extends ConsumerState<ReplaceProfilePhotoButton> {
  bool _isLoading = false;

  Future<void> _replace() async {
    final l10n = AppLocalizations.of(context)!;

    if (!ref.read(isVerifiedProvider)) {
      CustomSnackbarHelper.show(context, text: l10n.replacePhotoNeedsVerification);
      return;
    }

    setState(() => _isLoading = true);

    String? error;
    try {
      error = await ref.read(userProvider.notifier).replaceProfilePicture(l10n, oldUrl: widget.currentUrl);
    } catch (e) {
      debugPrint('Replace profile photo failed: $e');
      error = l10n.somethingWentWrong;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;
    if (error != null && error.isNotEmpty) {
      CustomSnackbarHelper.show(context, text: error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isVerified = ref.watch(isVerifiedProvider);

    return TextButton.icon(
      onPressed: _isLoading ? null : _replace,
      icon: _isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.photo_camera, size: 20),
      label: Text(l10n.replacePhoto),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: isVerified ? AppColors.blackTextFull : Theme.of(context).disabledColor,
      ),
    );
  }
}
