import 'package:capstone/core/shared/widgets/custom_navigation_bar.dart';
import 'package:capstone/features/public_user/main/views/home_screen.dart';
import 'package:capstone/features/public_user/map/views/map_screen.dart';
import 'package:capstone/features/public_user/pre_call_guidance/views/pre_call_guidance_screen.dart';
import 'package:capstone/features/public_user/profile/views/profile_screen.dart';
import 'package:capstone/features/public_user/reporting/views/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String address = "Brgy. Balibago, Angeles City";
  int currentPageIndex = 2;

  static const _navItems = [
    CustomNavigationBarItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Map'),
    CustomNavigationBarItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'Reports'),
    CustomNavigationBarItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    CustomNavigationBarItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: 'Guidance'),
    CustomNavigationBarItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = const [
      MapScreen(),
      ReportsScreen(),
      HomeScreen(),
      PreCallGuidanceScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarColor: Colors.deepOrange),
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
