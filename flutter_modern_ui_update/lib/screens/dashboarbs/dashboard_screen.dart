import 'package:flutter/material.dart';
import 'package:flutter_modern_ui/constants.dart';
import 'dart:io';
import 'components/buttons/buttons_screen.dart';
import 'components/display_image.dart';
import 'components/results/detailed_result.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  File? _selectedImage;
  String _imageName = '';
  String resultLabel = "No Problem yet";
  double resultProbability = 0.0;
  Map<String, String> _allConfidences = {};

  void _updateSelectedImage(File image) {
    setState(() {
      _selectedImage = image;

      // Tách tên file không bao gồm đuôi mở rộng
      String fileName = image.path.split(Platform.pathSeparator).last;
      _imageName = fileName.split('.').first; // Loại bỏ phần mở rộng như .jpg, .png
    });
  }

  void updateResult(String newLabel, double probability, Map<String, String> allConfidences) {
    setState(() {
      resultLabel = newLabel;
      resultProbability = probability/100.0;
      _allConfidences = allConfidences;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // TODO: Header Area
            Row(
              children: [
                Text(
                  "Diagnosis",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 50),
            // TODO: Content Area
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      // TODO: Show Function Area
                      Buttons(
                        onImageSelected: _updateSelectedImage,
                        onResultReady: updateResult,
                        resultLabel: resultLabel,
                        resultProbability: resultProbability,
                      ),

                      SizedBox(height: 50),
                      // TODO: Display Image Area
                      DisplayImage(selectedImage: _selectedImage, imageName: _imageName,),
                    ],
                  ),
                ),
                SizedBox(width: defaultPadding),
                // TODO: Show Result Area
                Expanded(flex: 2, child: DetailedResult(problemLabel: resultLabel, probability: resultProbability, allConfidences: _allConfidences,)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
