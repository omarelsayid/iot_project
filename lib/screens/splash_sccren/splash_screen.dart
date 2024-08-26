import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/authentication_screens/login_screen.dart';
import 'package:iot_project/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  @override
  void initState() {
    super.initState();

    // Delayed function to check authentication state after splash screen
    Future.delayed(const Duration(seconds: 6), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          // If user is not logged in, navigate to the login screen
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ));
        } else {
          // If user is logged in, navigate to the main screen
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Center(
        child: SizedBox(
          width: 250.0,
          // Animated text widget for splash screen
          child: TextLiquidFill(
            text: 'IOT',
            waveColor: Colors.blueAccent,
            boxBackgroundColor: Colors.black,
            textStyle: GoogleFonts.pacifico(
              fontSize: 80.0,
              fontWeight: FontWeight.bold,
            ),
            boxHeight: 120.0,
          ),
        ),
      ),
    );
  }
}