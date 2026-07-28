import 'package:capstone/features/main/home_screen.dart';
import 'package:capstone/features/map/views/map_screen.dart';
import 'package:capstone/features/pre_call_guidance/views/pre_call_guidance_screen.dart';
import 'package:capstone/features/profile/views/profile_screen.dart';
import 'package:capstone/features/reporting/views/reports_screen.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
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
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.white);

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
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.deepOrange,
        backgroundColor: Colors.deepOrangeAccent,
        buttonBackgroundColor: Colors.deepOrange,
        index: currentPageIndex,
        animationDuration: Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.map,
              color: Colors.white,
            ),
            label: "Map",
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.chat,
              color: Colors.white,
            ),
            label: "Reports",
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.home,
              color: Colors.white,
            ),
            label: "Home",
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.menu_book,
              color: Colors.white,
            ),
            label: "Guidance",
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.account_circle,
              color: Colors.white,
            ),
            label: "Profile",
            labelStyle: labelStyle,
          ),
        ],
        onTap: (value) {
          setState(() {
            currentPageIndex = value;
          });
        },
      ),
    );
  }
}
