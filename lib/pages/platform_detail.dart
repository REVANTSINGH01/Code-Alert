import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
class PlatformDetail extends StatefulWidget{
  final List<String> selectedPlatforms;
  const PlatformDetail({super.key, required this.selectedPlatforms});

  @override
  State<PlatformDetail> createState() => _PlatformDetail();
}
class _PlatformDetail extends State<PlatformDetail>{
  final cfController =
  TextEditingController();

  final lcController =
  TextEditingController();

  final ccController =
  TextEditingController();

  bool isLoading = false;

  // Save Handles Function
  Future<void> saveHandles() async {

    setState(() {
      isLoading = true;
    });

    try {
      final prefs =
      await SharedPreferences.getInstance();

      String? userId =
      prefs.getString("user_id");

      if (userId == null) {
        throw Exception("User not found");
      }

      await ApiService.updateHandles(

        userId: userId,

        cfHandle:
        cfController.text.trim(),

        lcHandle:
        lcController.text.trim(),

        ccHandle:
        ccController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
          Text("Handles Saved"),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        '/home_page',
      );

    } catch (e) {

      print(e);

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
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
        title:
        const Text("Platform Handles"),
      ),

      body: Padding(

        padding:
        const EdgeInsets.all(20),

        child: SingleChildScrollView(

          child: Column(

            children: [

              if (widget.selectedPlatforms
                  .contains("codeforces"))

                TextField(

                  controller:
                  cfController,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "Codeforces Handle",
                  ),
                ),

              const SizedBox(height: 20),

              if (widget.selectedPlatforms
                  .contains("leetcode"))

                TextField(

                  controller:
                  lcController,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "LeetCode Handle",
                  ),
                ),

              const SizedBox(height: 20),

              if (widget.selectedPlatforms
                  .contains("codechef"))

                TextField(

                  controller:
                  ccController,

                  decoration:
                  const InputDecoration(

                    labelText:
                    "CodeChef Handle",
                  ),
                ),

              const SizedBox(height: 40),

              SizedBox(

                width: double.infinity,

                child: ElevatedButton(

                  onPressed:
                  isLoading
                      ? null
                      : saveHandles,

                  child: isLoading

                      ? const CircularProgressIndicator()

                      : const Text(
                    "Continue",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
 }
}