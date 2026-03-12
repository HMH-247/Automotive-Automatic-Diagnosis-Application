import 'package:flutter/material.dart';
import 'package:flutter_modern_ui/screens/dashboarbs/dashboard_screen.dart';

import 'dashboarbs/components/side_menu.dart';

class DiagnosisScreen extends StatelessWidget {
  const DiagnosisScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: SideMenu()),
            Expanded(flex: 5, child: DashboardScreen()),
          ],
        ),
      ),
    );
  }
}
