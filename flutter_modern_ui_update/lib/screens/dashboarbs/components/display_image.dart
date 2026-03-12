import 'dart:io';

import 'package:flutter/material.dart';

import '../../../constants.dart';

class DisplayImage extends StatelessWidget {
  const DisplayImage({super.key, required File? selectedImage, required this.imageName})
    : _selectedImage = selectedImage;

  final File? _selectedImage;
  final String imageName;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 430,
        padding: EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 350,
              ),
            )
                : Expanded(
              child: Center(
                child: Text(
                  'No image selected',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _selectedImage != null ? imageName : '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.amberAccent,           // Màu sáng nổi bật hơn
                fontSize: 18,                        // Tăng kích thước chữ
                fontWeight: FontWeight.bold,        // In đậm
                shadows: [                           // Tạo đổ bóng cho chữ nổi hơn
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    blurRadius: 3.0,
                    color: Colors.black54,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
