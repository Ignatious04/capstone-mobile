import 'package:capstone/core/shared/widgets/custom_navigation_bar.dart';
import 'package:capstone/features/responder/active_case/providers/responder_location_sharing_provider.dart';
import 'package:capstone/features/responder/active_case/views/active_case_screen.dart';
import 'package:capstone/features/responder/history/views/history_screen.dart';
import 'package:capstone/features/responder/profile/views/responder_profile_screen.dart';
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

  static const _navItems = [
    CustomNavigationBarItem(
      icon: Icons.local_hospital_outlined,
      activeIcon: Icons.local_hospital,
      label: 'Active Case',
    ),
    CustomNavigationBarItem(icon: Icons.history, activeIcon: Icons.history, label: 'History'),
    CustomNavigationBarItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(responderLocationSharingProvider);
    final pages = const [
      ActiveCaseScreen(),
      ResponderHistoryScreen(),
      ResponderProfileScreen(),
    ];

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(statusBarColor: Colors.deepOrange),
        child: IndexedStack(
          index: currentPageIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (value) => setState(() => currentPageIndex = value),
        items: _navItems,
      ),
    );
  }
}
