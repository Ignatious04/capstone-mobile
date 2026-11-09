import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_elevated_button.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/reporting/widgets/empty_card.dart';
import 'package:capstone/features/responder/active_case/providers/reporter_medical_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReporterMedicalInfoCard extends ConsumerStatefulWidget {
  const ReporterMedicalInfoCard({super.key, required this.reportID});

  final String reportID;

  @override
  ConsumerState<ReporterMedicalInfoCard> createState() => _ReporterMedicalInfoCardState();
}

class _ReporterMedicalInfoCardState extends ConsumerState<ReporterMedicalInfoCard> {
  bool _loading = false;
  bool _revealed = false;
  bool _failed = false;
  ReporterMedicalInfo? _info;

  // One tap = one server call = one audit entry.
  Future<void> _reveal() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    final provider = reporterMedicalInfoProvider(widget.reportID);
    try {
      final info = await ref.read(provider.future);
      if (!mounted) return;
      setState(() {
        _info = info;
        _revealed = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    } finally {
      ref.invalidate(provider); // don't cache; the next tap asks (and logs) again
      if (mounted) setState(() => _loading = false);
    }
  }

  String _num(double v) => v == 0 ? '—' : (v == v.roundToDouble() ? v.toInt().toString() : v.toString());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_revealed && _info == null) {
      return EmptyCard(icon: Icons.medical_information_outlined, message: l10n.noMedicalInfoShared);
    }

    return Card(
      color: AppColors.bgWhiteLight,
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _revealed
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelText(value: l10n.bloodType.toUpperCase()),
                  BodyText(value: _info!.bloodType.isEmpty ? '—' : _info!.bloodType, isBold: true),
                  const SizedBox(height: 10),
                  LabelText(value: l10n.heightCm.toUpperCase()),
                  BodyText(value: _num(_info!.height), isBold: true),
                  const SizedBox(height: 10),
                  LabelText(value: l10n.weightKg.toUpperCase()),
                  BodyText(value: _num(_info!.weight), isBold: true),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyText(value: l10n.medicalInfoAccessNote, color: AppColors.blackTextMuted, isBold: false),
                  const SizedBox(height: 10),
                  if (_failed) ...[
                    BodyText(value: l10n.medicalInfoLoadError, color: AppColors.danger, isBold: false),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: _loading
                        ? const Center(child: CustomCircularProgressIndicator())
                        : CustomElevatedButton(onPressed: _reveal, value: l10n.viewMedicalInfo),
                  ),
                ],
              ),
      ),
    );
  }
}