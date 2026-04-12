import 'package:flutter/material.dart';
class AboutApp extends StatelessWidget{
  const AboutApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : const Text("App Info"),
        // Text("Version : 1.0.0"),
      ),
    );
  }
}