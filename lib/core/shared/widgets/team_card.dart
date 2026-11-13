import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/team_model.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/label_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({super.key, required this.team, this.showMembers = false});

  final TeamModel team;
  final bool showMembers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Leader first.
    final memberIDs = [...team.memberIDs]
      ..sort((a, b) => a == team.teamLeaderID ? -1 : (b == team.teamLeaderID ? 1 : 0));

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: AppColors.bgWhiteLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.lighterBlack),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lighterGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.groups, size: 30, color: Colors.green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelText(value: l10n.team.toUpperCase()),
                      BodyText(value: team.teamName, isBold: true),
                      BodyText(value: l10n.memberCount(team.memberCount), color: AppColors.blackTextMuted),
                    ],
                  ),
                ),
              ],
            ),
            if (showMembers && memberIDs.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              for (final id in memberIDs) _MemberRow(responderID: id, isLeader: id == team.teamLeaderID),
            ],
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.responderID, required this.isLeader});

  final String responderID;
  final bool isLeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final responder = ref.watch(responderByIdProvider(responderID)).value;
    final name = (responder?.fullName.isNotEmpty ?? false) ? responder!.fullName : l10n.unnamedResponder;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isLeader ? Icons.star : Icons.person_outline,
            size: 25,
            color: isLeader ? Colors.amber : AppColors.blackTextMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyText(value: name, isBold: isLeader),
                if (isLeader) LabelText(value: l10n.teamLeader, color: AppColors.blackTextMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}