import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
          Card(
            margin: EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "CodeAlert helps developers track important alerts and updates in real-time.",style: TextStyle(
                fontSize: 15,
                height: 1.4,
              ),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.all(12),
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text("Developers"),
              subtitle: Text("Revant Singh\nNidhiansh Chauhan" ,style: TextStyle(fontSize: 16),),
            ),
          ),
          Card(
            margin: EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text("GitHub"),
                  trailing: Icon(Icons.open_in_new),
                  onTap:openGitHub,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text("Rate App"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: (){},
                ),
              ],
            ),
          ),
          Text(
            "© 2026 CodeAlert",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
  Future<void> openGitHub() async {
    final Uri url = Uri.parse("https://github.com/REVANTSINGH01/Code-Alert");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}