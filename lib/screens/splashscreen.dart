import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travelbuddy2/screens/bottom_nav_screen.dart';
import 'package:travelbuddy2/screens/login_screen.dart';
import '../utils/app_colors.dart' show kDarkBrown, kGrey, kWhite;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    navigateUser();
  }

  void navigateUser() async {
    await Future.delayed(const Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ✅ User already logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavScreen()),
      );
    } else {
      // ❌ Not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBrown,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Icon(Icons.travel_explore, size: 80, color: kGrey),

            SizedBox(height: 20),

            Text(
              "TravelBuddy",
              style: TextStyle(
                color: kGrey,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            CircularProgressIndicator(color: kWhite),
          ],
        ),
      ),
    );
  }
}