import 'package:flutter/material.dart';
import '../../../../constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DetailedResult extends StatelessWidget {
  // Store Detailed Problem
  final String problemLabel;
  final double probability;
  final Map<String, String> allConfidences;

  const DetailedResult({super.key, required this.problemLabel, required this.probability, required this.allConfidences});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 606,
      padding: EdgeInsets.all(defaultPadding),
      //height: 500,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Diagnostic Result",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),

          SizedBox(height: 50),
          // TODO: Perform Accuracy Result PirChart
          Center(
            child: CircularPercentIndicator(
              radius: 80.0,
              lineWidth: 13.0,
              animation: true,
              percent: probability,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Accuracy",
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    "${(probability * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: Colors.grey[850]!,
              progressColor: Colors.deepPurple,
            ),
          ),

          SizedBox(height: 20),
          ShowProblemCause(
            title: "Problem",
            svgSrc: "assets/icons/warning.svg",
            colorIcon: Colors.red,
            description: problemLabel,
          ),
          SizedBox(height: defaultPadding),

          // Show all_confidence
          ElevatedButton.icon(
            onPressed: () {
              if (allConfidences == null || allConfidences.isEmpty) return;

              // Tìm class có confidence cao nhất
              String highestKey = '';
              double highestValue = 0.0;
              allConfidences.forEach((k, v) {
                double conf = double.tryParse(v.replaceAll('%', '')) ?? 0.0;
                if (conf > highestValue) {
                  highestValue = conf;
                  highestKey = k;
                }
              });

              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                    child: Center(
                      child: Text(
                        'All Confidences',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  content: SizedBox(
                    width: 800,
                    height: 500,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: allConfidences.length,
                      itemBuilder: (context, index) {
                        String key = allConfidences.keys.elementAt(index);
                        String value = allConfidences[key]!;

                        double confidenceValue = double.tryParse(value.replaceAll('%', '')) ?? 0.0;
                        Color valueColor;
                        if (confidenceValue >= 80) {
                          valueColor = Colors.greenAccent.shade400;
                        } else if (confidenceValue >= 50) {
                          valueColor = Colors.orangeAccent.shade200;
                        } else {
                          valueColor = Colors.redAccent.shade200;
                        }

                        bool isHighest = key == highestKey;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    key,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                                      color: isHighest ? Colors.green : Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: valueColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.list),
            label: const Text(
              'Show All Confidences',
              textAlign: TextAlign.center,
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 50),
              textStyle: const TextStyle(fontSize: 16),
              alignment: Alignment.center,
            ),
          ),

        ],
      ),
    );
  }
}

class ShowProblemCause extends StatelessWidget {
  const ShowProblemCause({
    super.key,
    required this.title,
    required this.svgSrc,
    required this.colorIcon,
    required this.description,
  });

  final String title, svgSrc, description;
  final Color colorIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: defaultPadding),
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: primaryColor.withOpacity(0.15)),
        borderRadius: const BorderRadius.all(Radius.circular(defaultPadding)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: SvgPicture.asset(svgSrc, color: colorIcon),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
