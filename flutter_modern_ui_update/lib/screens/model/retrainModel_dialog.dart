import 'package:flutter/material.dart';
import 'dart:async';

class RetrainDialog extends StatefulWidget {
  final Future<void> Function() retrainModel;
  final Future<String> Function() getModelInfo;

  const RetrainDialog({
    Key? key,
    required this.retrainModel,
    required this.getModelInfo,
  }) : super(key: key);

  @override
  _RetrainDialogState createState() => _RetrainDialogState();
}

class _RetrainDialogState extends State<RetrainDialog> {
  int secondsElapsed = 0;
  Timer? _timer;
  String? modelInfo;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startRetrain();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  Future<void> _startRetrain() async {
    await widget.retrainModel();
    String info = await widget.getModelInfo();
    setState(() {
      modelInfo = info;
      isDone = true;
    });
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Retraining Model"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDone) ...[
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(),
                Text(
                  '$secondsElapsed s',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("Retraining in progress..."),
          ] else ...[
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 12),
            Text("Retrain complete!"),
            SizedBox(height: 12),
            Text("Model info:\n$modelInfo"),
          ],
        ],
      ),
      actions: isDone
          ? [
        TextButton(
          child: Text("Close"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ]
          : [],
    );
  }
}