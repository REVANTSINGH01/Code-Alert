import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/theme_provider.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/profilepage.dart';
import 'package:my_app/pages/settings.dart';
import 'package:my_app/pages/about_app.dart';
import 'package:my_app/pages/reminders.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/pages/sign_up.dart';
import 'package:my_app/pages/user_setup.dart';

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
      home: LoginPage(),
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/user_setup': (context) => const UserSetup(),
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

    );
  }
}