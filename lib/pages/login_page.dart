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

      final user = await ApiService.login(

        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
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
      await ApiService.syncDashboard();
      if(!mounted)return;
      print(user);
      Navigator.pushReplacementNamed(
        context,
        '/home_page',
      );
      print(user);

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Login Successful"),
        ),
      );

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),
      );

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