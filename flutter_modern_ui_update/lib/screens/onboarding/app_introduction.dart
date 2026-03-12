import 'package:flutter/material.dart';
import 'package:flutter_modern_ui/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AppIntroduction extends StatelessWidget {
  const AppIntroduction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: AppBar(
        title: Text(
          'About This App',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Purpose of the App',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This app is designed to help users quickly and accurately detect engine faults by leveraging a Machine Learning model to classify radar charts generated during the engine speed cycle. '
                  'By automating fault detection through intelligent pattern recognition, the app enhances diagnostic efficiency and supports proactive engine maintenance.',
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),
            Text(
              'About the Author',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'This app is created by Huynh Minh Hien, a student of K21 at the Faculty of Traffic Engineering, Ho Chi Minh City University of Technology. '
                  'With a strong interest in automotive systems and intelligent diagnostics, Hien developed this app as part of a capstone project, aiming to apply Machine Learning techniques to practical problems in engine fault detection.',
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 30),
            Text(
              'Instructor',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'MSc. Pham Tran Dang Quang is a lecturer at the Faculty of Traffic Engineering, Ho Chi Minh City University of Technology. '
                  'With expertise in vehicle engineering, he has provided valuable guidance and support throughout the development of this app, ensuring both technical accuracy and practical relevance.',
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
