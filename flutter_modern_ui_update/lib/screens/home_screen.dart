import 'package:flutter/material.dart';
import 'dashboarbs/components/side_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side menu
            Expanded(flex: 1, child: SideMenu()),
            // Main content
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/GLD.png',
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'General Layout Design of System',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description text
                    const Text(
                      '''The architecture of the proposed fault diagnosis system using continual learning and deep learning techniques is composed of five main components. Each part plays a critical role in enabling a seamless and intelligent diagnostic workflow, from raw data to a user-friendly desktop application. The architecture is modular, scalable, and designed to support real-time diagnostics and future updates.\n
1. Dataset Formation
The first phase involves collecting and preprocessing automotive sensor data in the form of radar charts, which includes fault and normal operational conditions of the engine. The raw data is cleaned, normalized, and labeled appropriately to form a structured dataset suitable for training. This dataset serves as the foundation for developing the machine learning model and is designed to be extensible for continual learning.\n
2. Model Training
In this stage, a deep learning model is trained on the preprocessed dataset. Depending on the use case, this model use Convolutional Neural Networks (CNNs) architectures. The training process involves hyperparameter tuning, validation, and performance evaluation using standard metrics like accuracy, precision, recall, and F1-score.\n
3. Continual Learning Workflow
The model is trained from scratch every time new fault classes or new radar charts of known fault classes need to add to the current dataset. The whole pipeline (data preprocessing and training) is automated.\n
4. FastAPI Server
The trained and continually updated model is deployed using FastAPI, a modern, high-performance web framework for building APIs in Python. This server acts as a backend, receiving input data from the client-side application, processing it through the model, and returning predictions and implementing continual learning.\n
5. Desktop Application
The final layer of the system is a cross-platform desktop application developed using Flutter framework. It provides a graphical user interface (GUI) for users (e.g., technicians or engineers) to upload engine data in the form of radar chart, view diagnostic results, and interact with continual learning workflow. The interface emphasizes usability and responsiveness, offering real-time feedback and visualizations of detected faults.
                      ''',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
