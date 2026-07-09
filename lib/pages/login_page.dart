import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool rememberMe = false; // Added state for the checkbox

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
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setBool("is_logged_in", true));
      if (!mounted) return;
      print(user);
      Navigator.pushReplacementNamed(context, '/main_layout');
      print("5 DONE");
    } catch (e) {
      // Optional: Add a SnackBar here to show the error to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ðŸŽ¨ UI Colors derived from your image
    const Color bgColor = Color(0xFF0B101A); // Deepest background blue/black
    const Color cardColor = Color(0xFF252936); // Slightly lighter card color
    const Color textPrimary = Colors.white;
    const Color textSecondary = Color(0xFFA0A5B1);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      // Removed the standard AppBar to match the edge-to-edge design
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: ConstrainedBox(

                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48.0, // minus vertical padding above
                ),
                child: Center(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ðŸ”· Title
                        const Text(
                          "Login",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // ðŸ”· Email Field
                        const Text(
                          "Email",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: textPrimary, fontSize: 16),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "example@mail.com",
                            hintStyle: const TextStyle(color: textSecondary, fontSize: 16),
                            suffixIcon: const Icon(Icons.mail_outline, color: textSecondary, size: 20),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: textSecondary, width: 0.5),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: textPrimary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ðŸ”· Password Field
                        const Text(
                          "Password",
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: textPrimary, fontSize: 16),
                          decoration: InputDecoration(
                            hintText: "12345#",
                            hintStyle: const TextStyle(color: textSecondary, fontSize: 16, letterSpacing: 2.0),
                            suffixIcon: const Icon(Icons.lock_outline, color: textSecondary, size: 20),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: textSecondary, width: 0.5),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: textPrimary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ðŸ”· Remember Me & Forgot Password Row
                        // Fixed: both sides now wrapped in Flexible + ellipsis so
                        // this Row can never overflow horizontally on narrow
                        // screens or with larger system font scales.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          rememberMe = value ?? false;
                                        });
                                      },
                                      fillColor: WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(WidgetState.selected)) {
                                          return textPrimary;
                                        }
                                        return Colors.transparent;
                                      }),
                                      checkColor: cardColor,
                                      side: const BorderSide(color: textSecondary, width: 1.5),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "REMEMBER ME",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "FORGET PASSWORD",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // ðŸ”· Login Button
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black, // Text color
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              "Log In",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ðŸ”· Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "DON'T HAVE AN ACCOUNT? ",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/signup',
                                      (route) => false,
                                );
                              },
                              child: const Text(
                                "REGISTER",
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  decoration: TextDecoration.underline,
                                  decorationColor: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}