import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    Color textColor = theme.bgColor == const Color(0xFF121212) ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        backgroundColor: theme.bgColor,
        title: Text(
          "Admin Control Panel",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Center(
        child: Text(
          "God Mode Activated 🚀\n\n(Scraper controls and analytics will go here)",
          textAlign: TextAlign.center,
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
    );
  }
}