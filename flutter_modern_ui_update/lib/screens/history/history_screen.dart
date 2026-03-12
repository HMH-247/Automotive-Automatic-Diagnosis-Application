import 'package:flutter/material.dart';
import 'package:flutter_modern_ui/screens/dashboarbs/components/side_menu.dart';
import 'package:flutter_modern_ui/constants.dart';
import 'package:flutter_modern_ui/screens/model/button_list.dart';
import 'package:flutter_modern_ui/screens/history_data.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Map<String, List<String>> imageMap = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: SideMenu()),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // TODO: Header Area
                    Row(
                      children: [
                        Text(
                          "History",
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
                          flex: 2,
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              padding: EdgeInsets.all(defaultPadding),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: HistoryData().savedResults.map((result) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (result['image'] != null)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: 300, // Giới hạn chiều rộng tối đa, bạn có thể thay đổi
                                                  maxHeight: 200, // Giới hạn chiều cao tối đa
                                                ),
                                                child: Image.file(
                                                  result['image'],
                                                  fit: BoxFit.contain, // Giữ tỉ lệ ảnh, vừa trong box
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          if (result['imageName'] != null)
                                            Text(
                                              "Image Name: ${result['imageName']}",
                                              style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                            ),
                                          Text(
                                            "Fault Cause: ${result['label']}",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Accuracy of Diagnosis: ${(result['probability'] * 100).toStringAsFixed(2)}%",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Diagnostic Result saved at: ${result['timestamp']}",
                                            style: TextStyle(color: Colors.white38, fontSize: 12),
                                          ),
                                          Divider(color: Colors.white24),
                                        ],
                                      )
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: defaultPadding),
                        // TODO: Show Result Area

                      ],
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
