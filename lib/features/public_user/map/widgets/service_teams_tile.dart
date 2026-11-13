import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/team_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceTeamsTile extends ConsumerWidget {
  const ServiceTeamsTile({super.key, required this.serviceID});

  final String serviceID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final teams = ref.watch(teamsForServiceProvider(serviceID)).value ?? const [];

    if (teams.isEmpty) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 10),
        leading: const Icon(Icons.groups, color: Colors.green, size: 25),
        title: BodyText(value: '${l10n.medicalTeams} (${teams.length})', isBold: true),
        children: [
          for (final team in teams)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(child: BodyText(value: team.teamName)),
                  BodyText(value: l10n.memberCount(team.memberCount), color: AppColors.blackTextMuted),
                ],
              ),
            ),
        ],
      ),
    );
  }
}