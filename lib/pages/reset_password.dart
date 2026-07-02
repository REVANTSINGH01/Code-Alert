import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token; // The secure token from Step 2

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText1 = true;
  bool _obscureText2 = true;

  // CodeAlert Dark Theme Colors
  final Color bgColor = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color textColor = Colors.white;
  final Color neonCyan = const Color(0xFF00FFCC);

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TASK 1: Send the new password and the secure token to the backend
      await ApiService.resetPassword(
        token: widget.token,
        newPassword: password,
      );

      if (!mounted) return;

      // Show Success Message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Password reset successfully! Please log in.", style: TextStyle(color: Colors.black)),
            backgroundColor: Color(0xFF00FFCC)
        ),
      );

      // TASK 2: Route the user to the Login Page and clear screen history
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false, // This prevents the user from hitting the Android "Back" button to return here
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: cardColor,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: neonCyan, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.password, size: 60, color: Color(0xFF00FFCC)),
            const SizedBox(height: 24),
            Text("Create New Password", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              "Your new password must be different from previously used passwords.",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 40),

            // Password Field
            _buildPasswordField(
              controller: _passwordController,
              hintText: "New Password",
              obscureText: _obscureText1,
              toggleVisibility: () => setState(() => _obscureText1 = !_obscureText1),
            ),
            const SizedBox(height: 16),

            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: _obscureText2,
              toggleVisibility: () => setState(() => _obscureText2 = !_obscureText2),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text("Reset Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}