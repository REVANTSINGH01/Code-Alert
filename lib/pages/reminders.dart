import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../services/api_service.dart';
import 'main_layout.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  bool isLoading = false;
  List reminders = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  Future<void> loadReminders() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final data = await ApiService.getReminders();
      if (!mounted) return;

      setState(() {
        reminders = data;
      });
    } catch (e) {
      print(e);
      // Fallback/Mock data for UI testing if API fails
      if(mounted && reminders.isEmpty){
        setState(() {
          reminders = [
            {"contest_name": "LeetCode Weekly Contest 380", "platform": "LeetCode", "start_time": "01d 04h 32m 15s", "date": "Today, 8:00 PM", "active": true},
            {"contest_name": "CodeChef Starters 115", "platform": "CodeChef", "start_time": "02d 11h 05m 40s", "date": "Jan 21, 2024", "time": "Wed, 7:30 PM", "active": true},
            {"contest_name": "Codeforces Round 919 (Div. 2)", "platform": "Codeforces", "start_time": "05h 22m 10s", "date": "Today, 10:00 PM", "active": true},
          ];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Helper function to get icons just like in your home page
  String getIcon(String? platform) {
    switch (platform?.toLowerCase()) {
      case "codeforces": return "assets/svgs/code-forces.svg";
      case "leetcode": return "assets/svgs/leetcode.svg";
      case "codechef": return "assets/svgs/codechef.svg";
      default: return "assets/svgs/code-forces.svg"; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // Dynamic colors
    Color textColor = theme.bgColor == const Color(0xFF121212) ? Colors.white : Colors.black;
    Color cardColor = theme.bgColor == const Color(0xFF121212) ? const Color(0xFF16161A) : Colors.white; // Slightly lighter than pure black for cards
    Color accentBlue = const Color(0xFF00E5FF); // Neon cyan color from your screenshot

    // Filter reminders based on search query
    final filteredReminders = reminders.where((r) {
      final title = r["contest_name"]?.toString().toLowerCase() ?? "";
      return title.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: theme.bgColor,

      appBar: AppBar(
        backgroundColor: theme.bgColor,
        elevation: 0,
        title: Text(
          "Reminders",
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textColor.withValues(alpha:0.7)),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: theme.bgColor == const Color(0xFF121212)
                    ? Colors.white.withValues(alpha:0.08)
                    : Colors.grey.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: TextStyle(color: textColor),
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: textColor.withValues(alpha:0.5)),
                  hintText: "Search reminders...",
                  hintStyle: TextStyle(color: textColor.withValues(alpha:0.5)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 📋 List of Reminders
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: accentBlue))
                : RefreshIndicator(
              color: accentBlue,
              onRefresh: loadReminders,
              child: filteredReminders.isEmpty
                  ? Center(
                child: Text(
                  "No reminders found.",
                  style: TextStyle(color: textColor.withValues(alpha:0.6), fontSize: 16),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: filteredReminders.length,
                itemBuilder: (context, index) {
                  final reminder = filteredReminders[index];
                  bool isActive = reminder["active"] ?? true;
                  bool isDarkMode = theme.bgColor == const Color(0xFF121212);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode?Colors.cyanAccent:Colors.white.withValues(alpha:0.05),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🔷 Platform Icon
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SvgPicture.asset(
                            getIcon(reminder["platform"]),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 🔷 Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder["contest_name"] ?? "Contest Name",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (reminder["date"] != null) ...[
                                Text(
                                  "Date: ${reminder["date"]}",
                                  style: TextStyle(
                                    color: textColor.withValues(alpha:0.6),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                "Starts in: ${reminder["start_time"] ?? '--'}",
                                style: TextStyle(
                                  color: textColor.withValues(alpha:0.8),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                reminder["time"] ?? reminder["date"] ?? '--',
                                style: TextStyle(
                                  color: textColor.withValues(alpha:0.6),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🔷 Toggle Switch
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Switch(
                              value: isActive,
                              onChanged: (val) {
                                setState(() {
                                  // TODO: Update state locally and send to backend
                                  reminder["active"] = val;
                                });
                              },
                              activeThumbColor: Colors.white,
                              activeTrackColor: accentBlue,
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.withValues(alpha:0.3),
                            ),
                            Text(
                              isActive ? "Active" : "Off",
                              style: TextStyle(
                                color: isActive ? accentBlue : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}