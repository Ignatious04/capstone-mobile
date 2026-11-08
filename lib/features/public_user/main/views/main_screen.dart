import 'package:capstone/core/l10n/app_localizations.dart';
import 'package:capstone/core/shared/providers/main_tab_provider.dart';
import 'package:capstone/core/shared/widgets/custom_navigation_bar.dart';
import 'package:capstone/core/themes/app_colors.dart';
import 'package:capstone/features/public_user/main/views/home_screen.dart';
import 'package:capstone/features/public_user/map/views/map_screen.dart';
import 'package:capstone/features/public_user/pre_call_guidance/views/pre_call_guidance_screen.dart';
import 'package:capstone/features/public_user/profile/views/profile_screen.dart';
import 'package:capstone/features/public_user/reporting/views/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  List<CustomNavigationBarItem> _navItems(AppLocalizations l10n) => [
    CustomNavigationBarItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: l10n.map),
    CustomNavigationBarItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: l10n.reports),
    CustomNavigationBarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: l10n.home),
    CustomNavigationBarItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: l10n.guidance),
    CustomNavigationBarItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: l10n.profile),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentPageIndex = ref.watch(mainTabProvider);
    final pages = const [
      MapScreen(),
      ReportsScreen(),
      HomeScreen(),
      PreCallGuidanceScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: AppColors.themeColor),
        child: IndexedStack(
          index: currentPageIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (value) => ref.read(mainTabProvider.notifier).set(value),
        items: _navItems(l10n),
      ),
    );
  }
}
