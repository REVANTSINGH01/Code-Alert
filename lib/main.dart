import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider/theme_provider.dart';
import 'package:my_app/pages/home_page.dart';
import 'package:my_app/pages/profilepage.dart';
import 'package:my_app/pages/settings.dart';
import 'package:my_app/pages/about_app.dart';
import 'package:my_app/pages/reminders.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/pages/sign_up.dart';
import 'package:my_app/pages/user_setup.dart';
import 'package:my_app/pages/admin_dashboard.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs=await SharedPreferences.getInstance();
  bool logged = prefs.getBool("is_logged_in") ?? false;
  if(logged){
    try{
      print("AUTO LOGIN SYNC");
      await ApiService.syncDashboard();
    }
    catch(e){
      print(e);
    }
  }
  String? token=prefs.getString("token");
  Widget startPage;
  if (token != null) {
    startPage = HomePage();
  } else {
    startPage = LoginPage();
  }

  runApp(
    ChangeNotifierProvider(create: (_)=>ThemeProvider(),
      child: MyApp(
        startPage:startPage,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({super.key,required this.startPage});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: startPage,
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/user_setup': (context) => const UserSetup(),
        '/home_page': (context) => HomePage(),
        '/profilepage': (context) => ProfilePage(),
        '/settings' : (context) => Settings(),
        '/about_app' : (context) => AboutApp(),
        '/reminders' : (context) => RemindersPage(),

        '/admin_dashboard' : (context) => const AdminDashboardPage(),

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