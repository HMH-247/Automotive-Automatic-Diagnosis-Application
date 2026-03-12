# Automatic Engine Fault Diagnosis System

## Project Overview
In the rapidly advancing field of automotive technology, electronic control systems in engines have become increasingly complex. Conventional diagnostic procedures like Symptom-System-Component-Cause (SSCC) are often time-consuming and heavily reliant on the skill and experience of highly trained technicians. 

This project aims to develop an automatic, user-friendly engine fault diagnosis system that aligns with modern trends in automotive digitalization. By collecting live engine data from the On-Board Diagnostics (OBD-II) system during a controlled engine speed cycle, the system transforms raw data into radar chart visualizations. These diagnostic images are then classified using a Convolutional Neural Network (CNN) to accurately identify specific fault causes. 

Beyond fault detection, the system integrates a continual learning architecture. This allows users to expand the diagnostic image dataset and retrain the AI model, ensuring continuous improvement in diagnostic accuracy and an extended fault detection range over time.

## Key Features
* **Hardware Data Acquisition:** Collects real-time engine sensor values via the vehicle's OBD-II port using an ESP32 microcontroller and the MCP2515 CAN bus module.
* **Signal Processing & Visualization:** Utilizes LabVIEW algorithms to convert raw engine sensor values into distinctive radar chart diagnostic images that reflect the engine's operational state.
* **AI-Powered Image Classification:** Employs a CNN model to classify radar charts and detect faults in D-Jetronic and GDI engines effectively.
* **Continual Learning Architecture:** Features a robust backend server built with Python that stores datasets, serves diagnostic results, and retrains the model to adapt to new fault patterns.
* **Cross-Platform UI:** Provides a seamless user experience through a Flutter application, clearly displaying diagnostic results and identifying the root causes of faults.
* **Cloud Infrastructure:** Hosted and deployed on an Azure Virtual Machine for reliable dataset storage and model serving.

## Technology Stack
* **Programming Languages:** Python, C++, Dart
* **Frontend:** Flutter
* **Backend & API:** FastAPI, Python
* **Machine Learning:** Convolutional Neural Network (CNN), Continual Learning Architecture
* **Hardware & Protocols:** ESP32, MCP2515, OBD-II, CAN Protocol
* **Data Processing:** LabVIEW
* **Database Management System:** MySQL

## System Data Flow
1. **Acquisition:** The ESP32 and MCP2515 modules interface with the engine's CAN network to extract live sensor data.
2. **Transformation:** Data is routed into LabVIEW, which translates the signals into radar chart images representing normal or abnormal engine conditions.
3. **Inference:** The FastAPI Python server on Azure receives the images and runs the CNN classification.
4. **Presentation:** The Flutter mobile application retrieves the analysis and displays the specific root cause to the technician.
5. **Evolution:** Users can feed new, validated diagnostic images back into the Python server to update the dataset and retrain the CNN.

## About the Developer
Developed by **Huynh Minh Hien**. This project represents a practical translation of theoretical automotive engineering principles—such as vehicle structure, engine theory, and control systems—into a modern, AI-driven software solution. It serves as a foundational step toward applying cutting-edge automation technology to enhance technician performance and vehicle maintenance quality.
