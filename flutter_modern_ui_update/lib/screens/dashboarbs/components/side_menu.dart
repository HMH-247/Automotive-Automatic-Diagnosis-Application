import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_modern_ui/screens/home_screen.dart';
import 'package:flutter_modern_ui/screens/diagnosis_screen.dart';
import 'package:flutter_modern_ui/screens/model/model_screen.dart';
import 'package:flutter_modern_ui/screens/history/history_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(child: SvgPicture.asset("assets/icons/FAST_logo.svg", color: Colors.blue,)),
            DrawerListTitle(
              title: "Home",
              svgSrc: "assets/icons/home.svg",
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            DrawerListTitle(
              title: "Diagnosis",
              svgSrc: "assets/icons/tools.svg",
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DiagnosisScreen()),
                );
              },
            ),
            DrawerListTitle(
              title: "Model",
              svgSrc: "assets/icons/model.svg",
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ModelScreen()),
                );
              },
            ),
            DrawerListTitle(
              title: "History",
              svgSrc: "assets/icons/history-svgrepo-com.svg",
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTitle extends StatelessWidget {
  const DrawerListTitle({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.press,
  });

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      leading: SvgPicture.asset(svgSrc, height: 20, color: Colors.white54),
      title: Text(title, style: TextStyle(color: Colors.white54)),
    );
  }
}
