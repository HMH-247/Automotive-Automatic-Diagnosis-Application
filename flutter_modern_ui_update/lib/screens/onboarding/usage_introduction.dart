import 'package:flutter/material.dart';

class UsageIntroduction extends StatelessWidget {
  const UsageIntroduction({super.key});

  Widget stepSection(String stepTitle, String description, String imagePath, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(stepTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Center(
          child: Image.asset(
            imagePath,
            width: 800, // Giới hạn chiều rộng ảnh
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usage Introduction")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "USAGE INTRODUCTION",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "I. IMPLEMENTING DIAGNOSIS PROCEDURE",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            stepSection(
              "Step 1",
              "Click on “Choose image” button to select a desired radar chart image wanted to implement diagnosis",
              "assets/images/figure1.png",
              "Figure 1. Diagnosis Screen when “Choose image” button is clicked",
            ),
            stepSection(
              "Step 2",
              "Click on “Start Diagnosis” button to start diagnostic process",
              "assets/images/figure2.png",
              "Figure 2. Diagnosis Screen when “Start Diagnosis” button is clicked",
            ),
            stepSection(
              "Step 3",
              "Click on “Save Results” button to save diagnostic results for further diagnosis in the future",
              "assets/images/figure3.png",
              "Figure 3. Diagnosis Screen when “Save Results” button is clicked",
            ),
            const SizedBox(height: 20),
            const Text(
              "II. IMPLEMENTING CONTINUAL LEARNING WORKFLOW",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            stepSection(
              "Step 1",
              "Click on “Show Dataset” button to show all current folders and images in dataset",
              "assets/images/figure4.png",
              "Figure 4. Model Screen when “Show Dataset” button is clicked",
            ),
            stepSection(
              "Step 2",
              "Click on “Modify Dataset” button, a small window pop up showing 4 other buttons. These buttons are served as functions to modify dataset.",
              "assets/images/figure5.png",
              "Figure 5. Model Screen when “Modify Dataset” button is clicked",
            ),
            Center(
              child: Image.asset("assets/images/figure6.png", width: 800),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                "Figure 6. Model Screen after “Modify Dataset” button is clicked",
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            stepSection(
              "Step 3",
              "After completing modification of dataset, click on “Retrain Model” button to start continual learning process",
              "assets/images/figure7.png",
              "Figure 7. Model Screen after “Retrain Model” button is clicked",
            ),
            Center(
              child: Image.asset("assets/images/figure8.png", width: 800),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                "Figure 8. Model Screen after “Retrain Model” button is clicked",
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Image.asset("assets/images/figure9.png", width: 800),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                "Figure 9. Model Screen after retraining process is completed",
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
