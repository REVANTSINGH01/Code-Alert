import 'package:flutter/material.dart';
class AboutApp extends StatelessWidget{
  const AboutApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : const Text("App Info"),
      ),
      body:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("CodeAlert", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
            Text("Version 1.0.0", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("CodeAlert helps developers track important alerts and updates in real-time.",style: TextStyle(fontSize: 18),),

          ]

      ),
    );
  }
}