import 'package:flutter/material.dart';
import 'package:iot_project/screens/dash_boarding_screen.dart';
import 'package:iot_project/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // List of pages to be displayed based on the selected tab in BottomNavigationBar
  final List _pages = [
    const DashBoardScreen(),
    const ProfileScreen(),
  ];

  // Variable to keep track of the selected tab
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the selected page based on _pageIndex
      body: _pages[_pageIndex],
      
      // Bottom navigation bar for switching between pages
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,  // Highlights the current tab
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'DashBoard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (value) {
          // Update _pageIndex when a tab is tapped
          _pageIndex = value;
          // Trigger a rebuild to display the selected page
          setState(() {});
        },
      ),
    );
  }
}