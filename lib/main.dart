

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelbuddy2/screens/splashscreen.dart';

import 'providers/auth_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 Firebase Init (FIXED)
  await Firebase.initializeApp(

  );

  runApp(const TravelBuddyApp());
}

class TravelBuddyApp extends StatelessWidget {
  const TravelBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'TravelBuddy',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.lightGreen,
          scaffoldBackgroundColor: Colors.grey[100],
        ),

        home: const SplashScreen(),
      ),
    );
  }
}