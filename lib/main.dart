import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/theme_provider.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/profilepage.dart';
import 'package:my_app/pages/settings.dart';
import 'package:my_app/pages/about_app.dart';
import 'package:my_app/pages/reminders.dart';


void main() {
  runApp(
    ChangeNotifierProvider(create: (_)=>ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/home_page': (context) => HomePage(),
        '/profilepage': (context) => ProfilePage(),
        '/settings' : (context) => Settings(),
        '/about_app' : (context) => AboutApp(),
        '/reminders' : (context) => Reminders(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      // appBar: AppBar(
      //   title: const Text("CodeAlert"),
      // ),
      //
      // body: const Center(
      //   child: Text("Main Page"),
      // ),
    );
  }
}