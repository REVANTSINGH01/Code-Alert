import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'reset_password.dart';
class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  final Color bgColor = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color textColor = Colors.white;
  final Color neonCyan = const Color(0xFF00FFCC);

  Future<void> _verifyCode() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Send the OTP and Email to the backend
      final token = await ApiService.verifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;

      // 2. Success! Navigate to the final Reset Password screen, passing the secure token
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Code verified!"), backgroundColor: Color(0xFF00FFCC)),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResetPasswordPage(token: token)),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.mark_email_read, size: 60, color: Color(0xFF00FFCC)),
            const SizedBox(height: 24),
            Text("Enter Code", style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              "We sent a 6-digit code to ${widget.email}. Enter it below to verify your identity.",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 40),

            // OTP Input Field
            TextField(
              controller: _otpController,
              style: TextStyle(color: textColor, fontSize: 24, letterSpacing: 8.0), // Spaced out for OTP look
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6, // Restrict to 6 digits
              decoration: InputDecoration(
                counterText: "", // Hide the 0/6 character counter
                hintText: "------",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), letterSpacing: 8.0),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: neonCyan, width: 1.5),
                ),
              ),
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
                onPressed: _isLoading ? null : _verifyCode,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text("Verify Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}