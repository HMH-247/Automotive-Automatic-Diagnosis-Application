import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_modern_ui/constants.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter_modern_ui/screens/onboarding/onboarding_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of the application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Automated Diagnosis',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
        canvasColor: secondaryColor,
      ),
      home: AnimatedSplashScreen(
        splash: 'assets/splash_screen/intro.gif',
        splashIconSize: 2000.0,
        centered: true,
        nextScreen: OnboardingScreen(),
        backgroundColor: Color(0xFF08003F),
        duration: 5000, // 5 seconds
      ),
    );
  }
}
