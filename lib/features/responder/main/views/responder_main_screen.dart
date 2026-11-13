import 'package:capstone/core/enums/service_type_enum.dart';
import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/responder_provider.dart';
import 'package:capstone/core/shared/widgets/custom_navigation_bar.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/responder/active_case/providers/responder_location_sharing_provider.dart';
import 'package:capstone/features/responder/active_case/views/active_case_screen.dart';
import 'package:capstone/features/responder/history/views/history_screen.dart';
import 'package:capstone/features/responder/profile/views/responder_profile_screen.dart';
import 'package:capstone/features/responder/schedule/views/responder_schedule_screen.dart';
import 'package:capstone/features/responder/teams/responder_teams_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponderMainScreen extends ConsumerStatefulWidget {
  const ResponderMainScreen({super.key});

  @override
  ConsumerState<ResponderMainScreen> createState() => _ResponderMainScreenState();
}

class _ResponderMainScreenState extends ConsumerState<ResponderMainScreen> {
  int currentPageIndex = 0;

  List<CustomNavigationBarItem> _navItems(AppLocalizations l10n, bool showTeams) => [
    CustomNavigationBarItem(
      icon: Icons.local_hospital_outlined,
      activeIcon: Icons.local_hospital,
      label: l10n.activeCase,
    ),
    CustomNavigationBarItem(icon: Icons.history, activeIcon: Icons.history, label: l10n.history),
    if (showTeams) CustomNavigationBarItem(icon: Icons.groups_outlined, activeIcon: Icons.groups, label: l10n.teams),
    CustomNavigationBarItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: l10n.schedule),
    CustomNavigationBarItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: l10n.profile),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.watch(responderLocationSharingProvider);
    final showTeams = ref.watch(currentAuthenticatedResponderProvider).value?.department == ServiceTypeEnum.medical;
    final pages = [
      const ActiveCaseScreen(),
      const ResponderHistoryScreen(),
      if (showTeams) const ResponderTeamsScreen(),
      const ResponderScheduleScreen(),
      const ResponderProfileScreen(),
    ];
    final index = currentPageIndex.clamp(0, pages.length - 1);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarColor: AppColors.themeColor),
        child: Stack(
          fit: StackFit.expand,
          children: [
            IndexedStack(
              index: index,
              children: pages,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: index,
        onTap: (value) => setState(() => currentPageIndex = value),
        items: _navItems(l10n, showTeams),
      ),
    );
  }
}
