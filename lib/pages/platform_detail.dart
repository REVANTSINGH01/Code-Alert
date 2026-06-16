import 'package:flutter/material.dart';
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
      if(cfController.text.trim().isEmpty && lcController.text.trim().isEmpty && ccController.text.trim().isEmpty){
        throw Exception(
            "Enter at least one handle"
        );
      }

      await ApiService.updateHandles(
        cfHandle:
        cfController.text.trim(),

        lcHandle:
        lcController.text.trim(),

        ccHandle:
        ccController.text.trim(),
      );
      await ApiService.syncDashboard();
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
        '/main_layout',
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
  void dispose() {
    cfController.dispose();
    lcController.dispose();
    ccController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.selectedPlatforms);
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

                if(widget.selectedPlatforms
                    .map((e)=>e.toLowerCase())
                    .contains("codeforces"))

                  TextField(
                    controller: cfController,
                    decoration: const InputDecoration(
                      labelText: "Codeforces Handle",
                    ),
                  ),

                const SizedBox(height:20),

                if(widget.selectedPlatforms
                    .map((e)=>e.toLowerCase())
                    .contains("leetcode"))

                  TextField(
                    controller: lcController,
                    decoration: const InputDecoration(
                      labelText: "LeetCode Handle",
                    ),
                  ),

                const SizedBox(height:20),

                if(widget.selectedPlatforms
                    .map((e)=>e.toLowerCase())
                    .contains("codechef"))

                  TextField(
                    controller: ccController,
                    decoration: const InputDecoration(
                      labelText: "CodeChef Handle",
                    ),
                  ),

                const SizedBox(height:40),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(

                    onPressed:
                    isLoading
                        ? null
                        : saveHandles,

                    child:

                    isLoading

                        ?

                    const CircularProgressIndicator()

                        :

                    const Text(
                      "Continue",
                    ),

                  ),

                ),
              ]
          ),
        ),
      ),
    );
 }
}