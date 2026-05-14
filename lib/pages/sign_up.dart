import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signup() async {

    setState(() {
      isLoading = true;
    });

    try {

      final user = await ApiService.signup(

        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Navigator.pushReplacementNamed(
        context,
        '/home_page',
      );
      
      print(user);

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(
          content: Text("Signup Successful"),
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
        title: const Text("Signup"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(
              controller: nameController,

              decoration: const InputDecoration(
                labelText: "Name",
              ),
            ),

            const SizedBox(height: 20),

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

              onPressed: isLoading ? null : signup,

              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Signup"),
            ),
          ],
        ),
      ),
    );
  }
}