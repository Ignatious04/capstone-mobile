import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/l10n/enum_labels.dart';
import 'package:capstone/core/shared/providers/locale_provider.dart';
import 'package:capstone/core/shared/widgets/custom_app_bar.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/guides/models/guides_model.dart';
import 'package:capstone/features/public_user/guides/providers/guides_provider.dart';
import 'package:capstone/features/public_user/guides/views/guides_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GuidesScreen extends ConsumerWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final language = ref.watch(localeProvider).languageCode;
    final guidesAsync = ref.watch(guideIndexProvider(language));

    return Scaffold(
      appBar: CustomAppBar(value: l10n.guidesTitle),
      body: SafeArea(
        child: guidesAsync.when(
          loading: () => const Center(child: CustomCircularProgressIndicator()),
          error: (_, _) => Center(
            child: BodyText(value: l10n.guidesLoadError, color: Colors.black54),
          ),
          data: (guides) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lighterThemeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.offline_pin_outlined,
                      size: 25,
                      color: AppColors.themeColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: BodyText(value: l10n.guidesOfflineNote)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              for (final type in ServiceTypeEnum.values)
                if (guides.any((g) => g.type == type)) ...[
                  SectionTitle(icon: type.guideIcon, title: type.label(l10n)),
                  const SizedBox(height: 10),
                  for (final guide in guides.where((g) => g.type == type)) ...[
                    _GuideCard(guide: guide),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 10),
                ],
              BodyText(value: l10n.guidesDisclaimer, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.guide});

  final GuideSummary guide;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.bgWhiteLight,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: guide)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: guide.type.guideBackground,
                child: Icon(guide.type.guideIcon, color: guide.type.guideColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleText(value: guide.title),
                    const SizedBox(height: 2),
                    BodyText(value: guide.summary, color: Colors.black54),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
