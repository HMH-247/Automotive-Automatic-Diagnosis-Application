import 'dart:io';

class HistoryData {
  static final HistoryData _instance = HistoryData._internal();

  factory HistoryData() => _instance;

  HistoryData._internal();

  final List<Map<String, dynamic>> savedResults = [];

  void addResult(String label, double probability, {File? image, String? imageName}) {
    savedResults.add({
      'label': label,
      'probability': probability,
      'timestamp': DateTime.now(),
      'image': image,
      'imageName': imageName,
    });
  }
}
