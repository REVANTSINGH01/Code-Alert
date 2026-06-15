import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {

    setState(() {
      isLoading = true;
    });

    try {
      print("1 LOGIN START");
      final user = await ApiService.login(

        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      print("2 API DONE");
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        "token",
        user["access_token"],
      );
      await prefs.setString(
        "user_id",
        user["user"]["id"],
      );
      await prefs.setString(
        "username",
        user["user"]["name"],
      );
      await prefs.setBool(
        "is_logged_in",
        true,
      );
      print("4 NAVIGATING");
      if(!mounted)return;
      print(user);
      Navigator.pushReplacementNamed(
        context,
        '/main_layout',
      );
      print("5 DONE");

    } catch (e) {
      print("LOGIN ERROR");
      print(e);

    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Login"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: emailController,

              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,

              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              onPressed: isLoading ? null : login,

              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Login"),
            ),

            const SizedBox(height: 20),

            Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                const Text(
                  "New to CodeAlert?",
                ),

                TextButton(

                  onPressed: () {

                    Navigator.pushNamed(
                      context,
                      '/signup',
                    );
                  },

                  child: const Text("SignUp"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}