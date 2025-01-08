import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configuración"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Text("Aquí van los ajustes"),
      ),
    );
  }
}
