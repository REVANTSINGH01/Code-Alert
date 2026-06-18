import 'package:flutter/material.dart';
import 'package:my_app/pages/main_layout.dart';
import 'package:my_app/pages/platform_detail.dart';

class UserSetup extends StatefulWidget {
  const UserSetup({super.key});

  @override
  State<UserSetup> createState() => _UserState();
}

class _UserState extends State<UserSetup> {
  List<String> connectedPlatforms = ["CodeChef"];
  // Global Theme Colors matching the image
  final Color bgColor = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("User Setup", style: TextStyle(color: textColor, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Connect\nPlatforms",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Sync your profiles to track rankings, upcoming contests, and global performance metrics across major coding environments.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Platform Cards ---
                  _buildPlatformCard(
                    platform: "Codeforces",
                    description: "Access weekly rounds and educational contests.",
                    iconData: Icons.bar_chart,
                    accentColor: const Color(0xFF8AB4F8), // Soft Blue
                    buttonColor: const Color(0xFF8AB4F8).withValues(alpha: 0.2),
                    buttonTextColor: const Color(0xFF8AB4F8),
                  ),
                  const SizedBox(height: 16),

                  _buildPlatformCard(
                    platform: "LeetCode",
                    description: "Daily challenges and technical interview prep.",
                    iconData: Icons.code,
                    accentColor: const Color(0xFFFFA116), // LeetCode Orange
                    buttonColor: const Color(0xFFFFA116),
                    buttonTextColor: Colors.black,
                  ),
                  const SizedBox(height: 16),

                  _buildPlatformCard(
                    platform: "CodeChef",
                    description: "Monthly long challenges and cook-offs.",
                    iconData: Icons.restaurant_menu,
                    accentColor: const Color(0xFF00B073), // CodeChef Green
                    buttonColor: Colors.transparent, // Not used when connected
                    buttonTextColor: Colors.white,
                    mockHandle: "CodeMaster_01",
                    mockRating: "2489",
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // --- Bottom Navigation Bar ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: (){
                        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=> const MainLayout(),),);
                      },
                      child: Text("Skip for Now", style: TextStyle(color: textColor)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8AB4F8), // Light Blue
                        foregroundColor: bgColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlatformDetail(
                              selectedPlatforms: List.from(connectedPlatforms),
                            ),
                          ),
                        );
                      },
                      child: const Text("Complete Setup", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔷 Reusable Widget for the Platform Cards
  Widget _buildPlatformCard({
    required String platform,
    required String description,
    required IconData iconData,
    required Color accentColor,
    required Color buttonColor,
    required Color buttonTextColor,
    String? mockHandle,
    String? mockRating,
  }) {
    bool isConnected = connectedPlatforms.contains(platform);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? accentColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon and Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: accentColor, size: 24),
              ),
              if (isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: accentColor, size: 12),
                      const SizedBox(width: 4),
                      Text("CONNECTED", style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                Text(
                  "AVAILABLE",
                  style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Titles
          Text(platform, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Bottom Action / Stats
          if (isConnected)
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mockHandle ?? "User", style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    Text("Rating: $mockRating", style: TextStyle(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                )
              ],
            )
          else
            SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // TODO: Open your _showEditHandleDialog here to actually connect!
                  setState(() {
                    connectedPlatforms.add(platform);
                  });
                },
                child: const Text("Connect Profile", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}