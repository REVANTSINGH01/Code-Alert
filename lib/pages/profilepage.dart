import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/theme_provider.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> with WidgetsBindingObserver {
  String username = "User";

  // Handles
  String? lcHandle;
  String? cfHandle;
  String? ccHandle;

  // Stats
  double? lcRating;
  int? cfRating;
  int? ccRating;
  int? lcSolved;
  int? cfSolved;
  int? ccSolved;
  String? cfRank;
  String? ccStars;

  bool loading = true;
  Timer? syncTimer;

  // CodeAlert Dark Theme Palette
  final Color bgColor = const Color(0xFF0F172A); // Deep Navy background
  final Color cardColor = const Color(0xFF1E293B); // Slate grey card
  final Color textColor = Colors.white;
  final Color textMuted = Colors.white70;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUser();
    });

    syncTimer = Timer.periodic(
      const Duration(minutes: 2),
          (_) {
        if (mounted) loadUser(showLoader: false);
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) loadUser(showLoader: false);
    }
  }

  Future<void> loadUser({bool showLoader = true}) async {
    try {
      if (showLoader && mounted) {
        setState(() => loading = true);
      }

      final prefs = await SharedPreferences.getInstance();
      final dashboard = await ApiService.syncDashboard();

      if (!mounted) return;

      setState(() {
        username = prefs.getString("username") ?? "User";

        lcHandle = dashboard["leetcode"]?["lc_handle"];
        cfHandle = dashboard["codeforces"]?["cf_handle"];
        ccHandle = dashboard["codechef"]?["cc_handle"];

        lcRating = dashboard["leetcode"] != null ? double.tryParse(dashboard["leetcode"]["rating"].toString()) : null;
        cfRating = dashboard["codeforces"] != null ? int.tryParse(dashboard["codeforces"]["rating"].toString()) : null;
        ccRating = dashboard["codechef"] != null ? int.tryParse(dashboard["codechef"]["rating"].toString()) : null;

        lcSolved = dashboard["leetcode"]?["problems_solved"];
        cfSolved = dashboard["codeforces"]?["problems_solved"];
        ccSolved = dashboard["codechef"]?["problems_solved"];
        cfRank = dashboard["codeforces"]?["rank"];
        ccStars = dashboard["codechef"]?["stars"];

        loading = false;
      });
    } catch (e) {
      print(e);
      if (e.toString().contains("Session_Expired")) {
        syncTimer?.cancel();
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }
      if (mounted) setState(() => loading = false);
    }
  }

  // Dialog to edit handles
  Future<void> _showEditHandleDialog(String platformName, String apiKey, String? currentHandle) async {
    TextEditingController controller = TextEditingController(text: currentHandle);
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text("Update $platformName", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: controller,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter username",
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00FFCC))), // Neon Cyan focus
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFCC), // Neon Cyan button
                  foregroundColor: Colors.black,
                ),
                onPressed: isSaving ? null : () async {
                  setDialogState(() => isSaving = true);
                  try {
                    Map<String, String> payload = {apiKey: controller.text.trim()};
                    // TODO: await ApiService.updatePlatformHandles(payload);

                    await loadUser();
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    print("Error saving: $e");
                    setDialogState(() => isSaving = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to update: ${e.toString()}")),
                      );
                    }
                  }
                },
                child: isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }

  // 🔷 Top Area: Connected Platform Pills
  Widget _buildConnectedPill(String platform, String? handle, String apiKey, Color accentColor, IconData icon) {
    bool isConnected = handle != null && handle.isNotEmpty;
    return GestureDetector(
      onTap: () => _showEditHandleDialog(platform, apiKey, handle),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isConnected ? accentColor.withValues(alpha: 0.1) : cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isConnected ? accentColor.withValues(alpha: 0.5) : Colors.white24),
          boxShadow: isConnected ? [
            BoxShadow(color: accentColor.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isConnected ? Icons.check_circle : icon, color: isConnected ? accentColor : textMuted, size: 16),
            const SizedBox(width: 8),
            Text(
              isConnected ? "$platform Connected" : "Link $platform",
              style: TextStyle(
                color: isConnected ? textColor : textMuted,
                fontSize: 13,
                fontWeight: isConnected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔷 Detailed Stat Card Builder
  Widget _buildStatCard({
    required String platform,
    required String subtitle,
    required String rating,
    required double ratingPercentage, // 0.0 to 1.0 for the progress bar
    required Color accentColor,
    required IconData icon,
    required String activityValue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(platform, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                      Text(subtitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accentColor)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Rating Row
          Text("CURRENT RATING", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(rating, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: accentColor)),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratingPercentage,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Activity Row
          Text("ACTIVITY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.2)),
          const SizedBox(height: 4),
          Text(activityValue, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // Check which handles actually exist
    final bool hasLC = lcHandle != null && lcHandle!.isNotEmpty;
    final bool hasCF = cfHandle != null && cfHandle!.isNotEmpty;
    final bool hasCC = ccHandle != null && ccHandle!.isNotEmpty;
    final bool hasNoPlatforms = !hasLC && !hasCF && !hasCC;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text("Profile", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00FFCC)))
          : RefreshIndicator(
        color: const Color(0xFF00FFCC),
        backgroundColor: cardColor,
        onRefresh: () async {
          await loadUser();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // 🔷 Profile Header
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 45,
                      backgroundColor: Color(0xFF1E293B),
                      child: Icon(Icons.person, size: 45, color: Colors.white54),
                    ),
                    const SizedBox(height: 16),
                    Text(username, style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 🔷 Connected Platform Pills
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildConnectedPill("LeetCode", lcHandle, "lc_handle", const Color(0xFFFFA116), Icons.code),
                  _buildConnectedPill("Codeforces", cfHandle, "cf_handle", const Color(0xFF1F8ACB), Icons.bar_chart),
                  _buildConnectedPill("CodeChef", ccHandle, "cc_handle", const Color(0xFF00B073), Icons.restaurant_menu),
                ],
              ),
              const SizedBox(height: 40),

              // 🔷 Detailed Statistics Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detailed Statistics", style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => loadUser(),
                    child: const Text("Refresh All", style: TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.w600)), // Neon cyan
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔷 Conditional Rendering using "Collection if"

              // Show LeetCode Card only if linked
              if (hasLC)
                _buildStatCard(
                  platform: "LeetCode",
                  subtitle: "Rating & Stats",
                  rating: lcRating?.toStringAsFixed(0) ?? "--",
                  ratingPercentage: (lcRating ?? 0) / 3500.0,
                  accentColor: const Color(0xFFFFA116), // Leetcode Orange
                  icon: Icons.code,
                  activityValue: "${lcSolved?.toString() ?? "0"} Questions Solved",
                ),

              // Show Codeforces Card only if linked
              if (hasCF)
                _buildStatCard(
                  platform: "Codeforces",
                  subtitle: cfRank ?? "Unrated",
                  rating: cfRating?.toString() ?? "--",
                  ratingPercentage: (cfRating ?? 0) / 3500.0,
                  accentColor: const Color(0xFF1F8ACB), // Codeforces Blue
                  icon: Icons.bar_chart,
                  activityValue: "${cfSolved?.toString() ?? "0"} Questions Solved",
                ),

              // Show CodeChef Card only if linked
              if (hasCC)
                _buildStatCard(
                  platform: "CodeChef",
                  subtitle: ccStars ?? "Unrated",
                  rating: ccRating?.toString() ?? "--",
                  ratingPercentage: (ccRating ?? 0) / 3000.0,
                  accentColor: const Color(0xFF00B073), // CodeChef Green
                  icon: Icons.restaurant_menu,
                  activityValue: "${ccSolved?.toString() ?? "0"} Questions Solved",
                ),

              // 🔷 Fallback State: If NO platforms are linked yet
              if (hasNoPlatforms)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.link_off, size: 50, color: Colors.white38),
                      const SizedBox(height: 16),
                      Text(
                        "No platforms linked yet",
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tap the pills above to link your coding accounts and view your stats.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}