import 'package:flutter/material.dart';
class AboutApp extends StatelessWidget{
  const AboutApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : const Text("App Info"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage("assets/images/ic_launcher.png"),
          ),
          SizedBox(height: 10),
          Text(
            "CodeAlert",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            "Version 1.0.0",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}