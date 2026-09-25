import 'package:capstone/features/public_user/main/views/home_screen.dart';
import 'package:capstone/features/public_user/main/widgets/floating_nav_bar.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
      bottomNavigationBar: FloatingNavBar(
        currentIndex: currentPageIndex,
        onTap: (value) => setState(() => currentPageIndex = value),
      ),
    );
  }
}
