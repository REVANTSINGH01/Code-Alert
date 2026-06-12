import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import 'home_page.dart';
import 'reminders.dart';
import 'profilepage.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // The 3 main pages of your app
  final List<Widget> _pages = const [
    HomePage(),
    RemindersPage(), // Make sure this matches your actual Reminders class name
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    Color textColor = theme.bgColor == const Color(0xFF121212) ? Colors.white : Colors.black;
    Color cardColor = theme.bgColor == const Color(0xFF121212) ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.bgColor,

      // 🔷 IndexedStack keeps all pages alive in memory.
      // This means your API doesn't reload when you switch tabs!
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 🔷 The permanent Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        selectedItemColor: const Color(0xFF00E5FF),
        unselectedItemColor: textColor.withValues(alpha: 0.5),
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Instantly swaps the page without flickering
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: "Reminders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}