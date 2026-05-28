import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/theme_provider.dart';
import '../services/api_service.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  bool isLoading = false;
  List reminders = [];

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not load reminders"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    // 🎨 Dynamic colors matching your app's existing theme logic
    Color textColor = theme.bgColor == const Color(0xFF121212) ? Colors.white : Colors.black;
    Color cardColor = theme.bgColor == const Color(0xFF121212) ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: theme.bgColor,

      appBar: AppBar(
        backgroundColor: theme.bgColor,
        title: Text(
          "My Reminders",
          style: TextStyle(color: textColor),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: loadReminders,
        child: reminders.isEmpty
            ? Center(
          child: Text(
            "No reminders set.",
            style: TextStyle(color: textColor, fontSize: 16),
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];

            return Card(
              color: cardColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.alarm,
                  color: textColor,
                  size: 28,
                ),
                title: Text(
                  // Adjust this key if your backend sends a different name for the contest
                  reminder["contest_name"] ?? "Unknown Contest",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  // Adjust this key to match your backend JSON
                  reminder["reminder_time"] ?? "No time specified",
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () {
                    // TODO: Add ApiService.deleteReminder if you implement it on the backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Delete feature coming soon!")),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),

      // Floating Action Button to let the user add a new reminder
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can show a bottom sheet or a dialog here to take input for a new reminder
          // and then call ApiService.createReminder()
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Navigate to Create Reminder Form")),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}