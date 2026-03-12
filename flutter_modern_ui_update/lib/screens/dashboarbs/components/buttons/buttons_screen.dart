import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // For json.decode
import 'package:http/http.dart' as http; // For http.MultipartRequest
import 'package:flutter_modern_ui/screens/history_data.dart';

// Buttons Frame
class Buttons extends StatefulWidget {
  const Buttons({
    super.key,
    required this.onImageSelected,
    required this.onResultReady,
    required this.resultLabel,
    required this.resultProbability,
  });

  final Function(File) onImageSelected;
  final Function(String label, double probability, Map<String, String> allConfidences) onResultReady;
  final String resultLabel;
  final double resultProbability;

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  // Store hover states for each icon
  final List<bool> _isHovering = List.generate(
    3,
    (_) => false,
  ); // Hoover Effect

  File? pickedImage;
  final String baseUrl = 'http://127.0.0.1:8000';
  Map<String, String>? _allConfidences;


  // Choose Image Function for Choose Image Button
  Future<File?> chooseImage(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      return File(result.files.single.path!);
    } else {
      // User canceled or no file selected
      return null;
    }
  }

  Future<void> predictImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/predict'));
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Parse the response
      final decoded = json.decode(response.body);
      final label = decoded['predicted_class'] ?? 'Unknown';
      String confidenceStr = decoded['confidence'] ?? '0%';
      final probability = double.tryParse(confidenceStr.replaceAll('%', '')) ?? 0.0;

      // Pare all_confidence
      final rawConfidences = decoded['all_confidences'] as Map<String, dynamic>;
      _allConfidences = rawConfidences.map((key, value) => MapEntry(key, value.toString()));

      final Map<String, String> allConfidences = Map<String, String>.from(decoded['all_confidences'] ?? {});
      // Call your callback with parsed values
      widget.onResultReady(label, probability, allConfidences);

    } catch (e) {
      print('Error during prediction: $e');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Function", style: Theme.of(context).textTheme.titleMedium),
            // Add New Function Button
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical: defaultPadding,
                ),
              ),
              onPressed: () {},
              icon: Icon(Icons.add),
              label: Text("Add New"),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        GridView.builder(
          shrinkWrap: true,
          itemCount: 3,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3,
          ),
          itemBuilder: (context, index) {
            IconData icon;
            String label;
            VoidCallback? onTap;

            switch (index) {
              case 0:
                icon = Icons.image;
                label = "Choose Image";
                onTap = () async {
                  File? image = await chooseImage(context);
                  if (image != null) {
                    pickedImage = image;
                    widget.onImageSelected(image);
                  }
                };
                break;
              case 1:
                icon = Icons.play_arrow;
                label = "Start Diagnosis";
                onTap = () {
                  if (pickedImage != null) {
                    predictImage(pickedImage!);
                  }
                };
                break;
              case 2:
                icon = Icons.save;
                label = "Save Results";
                onTap = () {
                  if (pickedImage != null) {
                    // Lấy tên file từ đường dẫn, tách lấy phần tên không bao gồm đuôi
                    String fileName = pickedImage!.path.split(Platform.pathSeparator).last;
                    String imageNameWithoutExtension = fileName.split('.').first;
                    HistoryData().addResult(
                      widget.resultLabel,
                      widget.resultProbability,
                      image: pickedImage,
                      imageName: imageNameWithoutExtension, // tên ảnh
                    );

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Result saved successfully"),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("No image to save."),
                    ));
                  }
                };
                break;
              default:
                icon = Icons.help_outline;
                label = "Unknown";
            }

            return GestureDetector(
              onTap: onTap,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovering[index] = true),
                onExit: (_) => setState(() => _isHovering[index] = false),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                _isHovering[index]
                                    ? Colors.white.withOpacity(0.15)
                                    : Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow:
                                _isHovering[index]
                                    ? [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Icon(icon, color: Colors.white, size: 40),
                        ),
                      ),
                    ),

                    // Floating label below icon
                    if (_isHovering[index])
                      Positioned(
                        //right: 10,
                        top: 100,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

