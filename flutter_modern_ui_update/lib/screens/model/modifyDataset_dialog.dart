import 'package:flutter/material.dart';

class ModifyDatasetDialog extends StatelessWidget {
  final VoidCallback uploadImage;
  final VoidCallback uploadZip;
  final VoidCallback deleteFolders;
  final VoidCallback deleteImages;

  const ModifyDatasetDialog({
    super.key,
    required this.uploadImage,
    required this.uploadZip,
    required this.deleteFolders,
    required this.deleteImages,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("Modify Dataset")),
      content: SizedBox( // Set a max width for the dialog's content
        width: 200, // You can adjust this width as needed
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          // Stretch children to full width
          children: [
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.image),
              label: Align(
                alignment: Alignment.center,
                child: Text("Upload Image"),
              ),
              onPressed: () {
                Navigator.pop(context);
                uploadImage();
              },
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              icon: Icon(Icons.archive),
              label: Align(
                alignment: Alignment.center,
                child: Text("Upload ZIP File"),
              ),
              onPressed: () {
                Navigator.pop(context);
                uploadZip();
              },
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              icon: Icon(Icons.folder_delete),
              label: Align(
                alignment: Alignment.center,
                child: Text("Delete Folder"),
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteFolders();
              },
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              icon: Icon(Icons.delete),
              label: Align(
                alignment: Alignment.center,
                child: Text("Delete Image"),
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteImages();
              },
            ),
          ],
        ),
      ),
    );
  }
}