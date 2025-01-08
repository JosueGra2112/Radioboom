import 'package:flutter/material.dart';

class RadioPlayerScreen extends StatelessWidget {
  final String stationName;
  final String streamUrl;

  RadioPlayerScreen({required this.stationName, required this.streamUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stationName),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text(
          "Reproduciendo: $stationName\nURL: $streamUrl",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
