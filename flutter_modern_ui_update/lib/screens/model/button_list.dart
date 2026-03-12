
import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert'; // For json.decode
import 'package:http/http.dart' as http; // For http.MultipartRequest
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter_modern_ui/screens/model/modifyDataset_dialog.dart';
import 'package:flutter_modern_ui/screens/model/retrainModel_dialog.dart';

// Buttons Frame
class ButtonList extends StatefulWidget {
  const ButtonList({super.key, required this.onImagesFetched});

  final Function(Map<String, List<String>> imageData) onImagesFetched;


  @override
  State<ButtonList> createState() => _ButtonsState();
}

class _ButtonsState extends State<ButtonList> {
  // Variables
  final List<bool> _isHovering = List.generate(3, (_) => false);
  final String baseUrl = 'http://127.0.0.1:8000';
  final picker = ImagePicker();

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          width: 100, // 👈 Custom width
          alignment: Alignment.center,
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 50, left: MediaQuery.of(context).size.width / 2 - 200, right: MediaQuery.of(context).size.width / 2 - 200), // 👈 Center horizontally
        padding: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }



  // List Folders and Images Function
  Future<void> listAllImages() async {
    var response = await http.get(Uri.parse('$baseUrl/list-all-images/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final imagesByClass = Map<String, List<String>>.from(
          data['images_by_class'].map((k, v) => MapEntry(k, List<String>.from(v)))
      );
      widget.onImagesFetched(imagesByClass);
      _showNotification("Dataset loaded successfully ");
    }
  }

  Future<void> uploadImageToClass() async {
    String? className = await _promptUserForInput("Enter folder name (class):");
    if (className == null || className.trim().isEmpty) return;

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-image/'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
    request.fields['class_name'] = className;

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        _showNotification("Image uploaded successfully");
      } else {
        _showNotification("Image upload failed (Status: ${response.statusCode})");
      }
    } catch (e) {
      _showNotification("Upload failed: ${e.toString()}");
    }

  }

  Future<void> uploadZipFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null) return;

    Dio dio = Dio();
    FormData formData = FormData();

    for (var file in result.files) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(file.path!, filename: file.name),
      ));
    }

    try {
      final response = await dio.post('$baseUrl/upload-zip/', data: formData);

      if (response.statusCode == 200) {
        _showNotification("ZIP file uploaded successfully");
      } else {
        _showNotification("ZIP upload failed ❌ (Status: ${response.statusCode})");
      }
    } catch (e) {
      _showNotification("Upload error: ${e.toString()}");
    }
  }

  Future<void> deleteFolders() async {
    String? folderName = await _promptUserForInput("Enter folder name to delete:");
    if (folderName == null || folderName.trim().isEmpty) return;

    var response = await http.delete(
      Uri.parse('$baseUrl/remove-folders/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([folderName]),
    );
    if (response.statusCode == 200) {
      _showNotification("Folder deleted successfully");
    }

  }

  Future<void> deleteImages() async {
    String? imagePath = await _promptUserForInput("Enter image path (e.g., cat/image1.jpg):");
    if (imagePath == null || imagePath.trim().isEmpty) return;

    var response = await http.delete(
      Uri.parse('$baseUrl/remove-images/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode([imagePath]),
    );

    if (response.statusCode == 200) {
      _showNotification("Image deleted successfully");
    }
  }

  Future<String?> _promptUserForInput(String title) async {
    String? result;
    await showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter text here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => ModifyDatasetDialog(
                    uploadImage: uploadImageToClass,
                    uploadZip: uploadZipFiles,
                    deleteFolders: deleteFolders,
                    deleteImages: deleteImages,
                  ),
                );
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                result = controller.text;
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
    return result;
  }
  void _showRetrainDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RetrainDialog(
        retrainModel: retrainModel,
        getModelInfo: getModelInfo,
      ),
    );
  }


  Future<void> retrainModel() async {
    var response = await http.post(Uri.parse('$baseUrl/retrain'));
    if (response.statusCode != 200) {
      throw Exception("Failed to retrain model");
    }
  }

  Future<String> getModelInfo() async {
    var response = await http.get(Uri.parse('$baseUrl/model-info'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final modelModified = DateTime.parse(data["model_last_modified"]);
      final formatted = 'Date: ${modelModified.toLocal().toString().split(" ").first}  '
          'Time: ${modelModified.toLocal().toString().split(" ").last}';
      return formatted;
    } else {
      return "Failed to get model info";
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
            childAspectRatio: 3.7, // Adjust Button Container
          ),
          itemBuilder: (context, index) {
            IconData icon;
            String label;
            VoidCallback? onTap;

            switch (index) {
              case 0:
                icon = Icons.folder_open;
                label = "Show Dataset";
                onTap = () {
                  listAllImages();
                };
                break;
              case 1:
                icon = Icons.edit;
                label = "Modify Dataset";
                onTap = () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ModifyDatasetDialog(
                        uploadImage: uploadImageToClass,
                        uploadZip: uploadZipFiles,
                        deleteFolders: deleteFolders,
                        deleteImages: deleteImages,
                      );
                    },
                  );
                };

                break;
              case 2:
                icon = Icons.restart_alt;
                label = "Retrain Model";
                onTap = _showRetrainDialog;
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
                        top: 110,
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




