

import 'package:flutter/material.dart';
import 'package:travelbuddy2/chatboat/chatboat_screen.dart';

import 'package:travelbuddy2/screens/explore_screen.dart';
import 'package:travelbuddy2/screens/friends_screen.dart';
import 'package:travelbuddy2/screens/profile_screen.dart' show ProfileScreen;
import 'package:travelbuddy2/screens/trips_screen.dart';
import 'package:travelbuddy2/utils/app_colors.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {

  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ExploreScreen(),     // 🌍 Explore (NEW)
    TripsScreen(),       // 🧳 Trips
    ChatBoat(),    // 💬 Chat
    FriendsScreen(),     // 👥 Friends
    ProfileScreen(),     // 👤 Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kDarkBrown,
        unselectedItemColor: kTerracotta,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Explore",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: "Trips",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: "ChatBoat",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Friends",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],
      ),
    );
  }
}