import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/models/team_model.dart';
import 'package:capstone/core/shared/providers/firebase_auth_provider.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/providers/team_provider.dart';
import 'package:capstone/core/shared/widgets/custom_circular_progress_indicator.dart';
import 'package:capstone/core/shared/widgets/custom_header_widget.dart';
import 'package:capstone/core/shared/widgets/section_title.dart';
import 'package:capstone/core/shared/widgets/team_card.dart';
import 'package:capstone/core/shared/widgets/text/body_text.dart';
import 'package:capstone/core/shared/widgets/text/title_text.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderTeamsScreen extends ConsumerWidget {
  const ResponderTeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final uid = ref.watch(authStateProvider).value?.uid ?? '';
    final responder = ref.watch(currentAuthenticatedResponderProvider).value;

    final myTeamsAsync = ref.watch(teamsForMemberProvider(uid));
    final stationTeamsAsync = ref.watch(teamsForServiceProvider(responder?.assignedAgencyID ?? ''));

    final myTeams = myTeamsAsync.value ?? const <TeamModel>[];
    final myIds = myTeams.map((t) => t.id).toSet();
    final otherTeams = (stationTeamsAsync.value ?? const <TeamModel>[]).where((t) => !myIds.contains(t.id)).toList();

    final loading =
        (myTeamsAsync.isLoading && !myTeamsAsync.hasValue) || (stationTeamsAsync.isLoading && !stationTeamsAsync.hasValue);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: CustomHeaderWidget(title: l10n.teams, body: l10n.teamsSubtitle),
            ),
            Expanded(
              child: loading
                  ? const Center(child: CustomCircularProgressIndicator())
                  : (myTeams.isEmpty && otherTeams.isEmpty)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.groups_outlined, size: 100, color: AppColors.blackTextMuted),
                        const SizedBox(height: 10),
                        TitleText(value: l10n.noTeams),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        SectionTitle(icon: Icons.groups, title: l10n.myTeam),
                        const SizedBox(height: 10),
                        if (myTeams.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: BodyText(value: l10n.notOnTeam, color: AppColors.blackTextMuted),
                          )
                        else
                          for (final team in myTeams) TeamCard(team: team, showMembers: true),
                        if (otherTeams.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SectionTitle(icon: Icons.group_outlined, title: l10n.otherTeams),
                          const SizedBox(height: 10),
                          for (final team in otherTeams) TeamCard(team: team),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}