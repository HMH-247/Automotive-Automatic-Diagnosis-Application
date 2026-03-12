import 'package:flutter/material.dart';
import 'package:flutter_modern_ui/screens/dashboarbs/components/side_menu.dart';
import 'package:flutter_modern_ui/constants.dart';
import 'package:flutter_modern_ui/screens/model/button_list.dart';

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  Map<String, List<String>> imageMap = {};

  void handleImagesFetched(Map<String, List<String>> data) {
    setState(() {
      imageMap = data;
    });
  }

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
                          "Model",
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
                              ButtonList(onImagesFetched: handleImagesFetched),
                              SizedBox(height: 50),
                              // TODO: Display Image Path in Dataset
                              Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Container(
                                  height: 400,
                                  padding: EdgeInsets.all(defaultPadding),
                                  decoration: BoxDecoration(
                                    color: secondaryColor,
                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: imageMap.isEmpty
                                      ? Center(child: Text("No data loaded"))
                                      : ListView(
                                    children: imageMap.entries.map((entry) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Class name
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white30,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              entry.key,
                                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 8),

                                          // Image paths on separate lines
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: entry.value.map((img) {
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                child: Text(img),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 12),
                                          Divider(),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            ],
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
