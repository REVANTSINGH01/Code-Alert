import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../services/api_service.dart';
import 'main_layout.dart';
import '../models/reminder_model.dart';
import 'package:intl/intl.dart';
import '../widgets/reminder_bottom.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => RemindersPageState();
}

class RemindersPageState extends State<RemindersPage> {
  bool isLoading = false;
  List<Reminder> reminders = [];
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
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
<<<<<<< Updated upstream
=======
  Future<void> deleteReminder(String id) async {
    try {
      await ApiService.deleteReminder(id);

      if (!mounted) return;

      print("Deleting id: $id");

      for (final r in reminders) {
        print("Reminder id: ${r.id}");
      }

      setState(() {
        reminders.removeWhere((r) {
          print("Comparing ${r.id} with $id");
          return r.id == id;
        });

        print("Remaining reminders: ${reminders.length}");
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reminder deleted successfully"),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
  String formatDate(DateTime dateTime) {
    return DateFormat("dd MMM yyyy").format(dateTime.toLocal());
  }

  String formatTime(DateTime dateTime) {
    return DateFormat("hh:mm a").format(dateTime.toLocal());
  }
  Future<void> showDeleteDialog(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Reminder"),
          content: const Text(
            "Are you sure you want to delete this reminder?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteReminder(id);
    }
  }
>>>>>>> Stashed changes

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
      return r.contestName
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
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
                  final Reminder reminder = filteredReminders[index];
                  bool isActive = true;
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
                            getIcon(null),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 🔷 Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.contestName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.orange,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                    width: 75,
                                    child: Text(
                                      "Reminder",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    formatTime(reminder.reminderTime),
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.emoji_events_outlined,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                    width: 75,
                                    child: Text(
                                      "Contest",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    formatTime(reminder.contestStart),
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.blue,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                    width: 75,
                                    child: Text(
                                      "Date",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Text(
                                    formatDate(reminder.contestStart),
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
<<<<<<< Updated upstream

                        // 🔷 Toggle Switch
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Switch(
                              value: isActive,
                              onChanged: null,
                              activeThumbColor: Colors.white,
                              activeTrackColor: accentBlue,
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.withValues(alpha:0.3),
=======
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit_outlined,
                                color: accentBlue,
                              ),
                              onPressed: () async {
                                final updated = await showReminderBottomSheet(
                                  context: context,
                                  contest: {
                                    "name": reminder.contestName,
                                    "start_time": reminder.contestStart.toUtc().toIso8601String(),
                                  },
                                  isEdit: true,
                                  reminderId: reminder.id,
                                  currentReminderTime: reminder.reminderTime,
                                );

                                if (updated == true && mounted) {
                                  await loadReminders();
                                }
                              },
>>>>>>> Stashed changes
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