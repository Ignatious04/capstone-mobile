// lib/features/responder/views/responder_main_screen.dart
import 'package:capstone/features/responder/history/views/history_screen.dart';
import 'package:capstone/features/responder/main/views/responder_home_screen.dart';
import 'package:capstone/features/responder/profile/views/responder_profile_screen.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResponderMainScreen extends StatefulWidget {
  const ResponderMainScreen({super.key});

  @override
  State<ResponderMainScreen> createState() => _ResponderMainScreenState();
}

class _ResponderMainScreenState extends State<ResponderMainScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: Colors.white,
    );

    final pages = const [
      ResponderHomeScreen(),
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
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.deepOrange,
        backgroundColor: Colors.deepOrangeAccent,
        buttonBackgroundColor: Colors.deepOrange,
        index: currentPageIndex,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: const Icon(Icons.local_hospital, color: Colors.white),
            label: "Active Case",
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.history, color: Colors.white),
            label: "History",
            labelStyle: labelStyle,
          ),
          CurvedNavigationBarItem(
            child: const Icon(Icons.account_circle, color: Colors.white),
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