import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider/theme_provider.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // 🎨 Dynamic colors
    theme.bgColor == Colors.black ? Colors.white : Colors.black;
    Color textColor=theme.bgColor==const Color(0xFF121212)?Colors.white:Colors.black;
    Color bgColor=theme.bgColor==const Color(0xFF121212)?const Color(0xFF1E1E1E):Colors.white;
    Color cardColor =
    theme.bgColor == const Color(0xFF121212) ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.bgColor,

      appBar: AppBar(
        backgroundColor: theme.bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "App Info",

          style: TextStyle(color: textColor),
        ),
      ),

      body: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔷 App Icon
              const CircleAvatar(
                radius: 40,
                backgroundImage:
                AssetImage("assets/images/ic_launcher.png"),
              ),

              const SizedBox(height: 10),

              // 🔷 App Name
              Text(
                "CodeAlert",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              // 🔷 Version
              Text(
                "Version 1.0.0",
                style: TextStyle(
                  color:textColor,
                ),
              ),

              const SizedBox(height: 10),

              // 🔷 Description
              Card(
                color: cardColor,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "CodeAlert helps developers track important alerts and updates in real-time.",
                    style: TextStyle(color:textColor,fontSize: 15, height: 1.4),
                  ),
                ),
              ),

              // 🔷 Developers
              Card(
                color: cardColor,
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text("Developers",style: TextStyle(color: textColor)),
                  subtitle: Text(
                    "Revant Singh\nNidhiansh Chauhan",
                    style: TextStyle(fontSize: 16,color: textColor),
                  ),
                ),
              ),

              // 🔷 Actions
              Card(
                color: cardColor,
                margin: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.code),
                      title:Text("GitHub",style:TextStyle(color: textColor)),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: openGitHub,
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.star),
                      title: Text("Rate App",style:TextStyle(color: textColor)),
                      trailing:
                      const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔷 Footer
              Text(
                "© 2026 CodeAlert",
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔗 Open GitHub
  static Future<void> openGitHub() async {
    final Uri url =
    Uri.parse("https://github.com/REVANTSINGH01/Code-Alert");

    if (!await launchUrl(url,
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}