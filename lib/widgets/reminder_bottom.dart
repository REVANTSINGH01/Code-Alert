import 'package:flutter/material.dart';
import '../services/api_service.dart';

Future<void> showReminderBottomSheet({
  required BuildContext context,
  required Map contest,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1B1B26),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (_) => ReminderBottomSheet(
      contest: contest,
    ),
  );
}

class ReminderBottomSheet extends StatefulWidget {
  final Map contest;

  const ReminderBottomSheet({
    super.key,
    required this.contest,
  });

  @override
  State<ReminderBottomSheet> createState() =>
      _ReminderBottomSheetState();
}

class _ReminderBottomSheetState
    extends State<ReminderBottomSheet> {

  bool isLoading = false;

  final List<int> reminderOptions = [
    5,
    10,
    15,
    30,
    60,
    1440,
  ];

  int selectedMinutes = 15;

  String getLabel(int minutes) {
    if (minutes == 1440) {
      return "1 Day Before";
    }

    if (minutes >= 60) {
      return "${minutes ~/ 60} Hour Before";
    }

    return "$minutes Minutes Before";
  }

  Future<void> saveReminder() async {
    setState(() {
      isLoading = true;
    });

    try {
      final contestStartTime = DateTime.parse(
        widget.contest["start_time"],
      );

      final reminderDateTime = contestStartTime.subtract(
        Duration(minutes: selectedMinutes),
      );

      await ApiService.createReminder(
        contestName: widget.contest["name"],
        contestStart: DateTime.parse(widget.contest["start_time"])
            .toUtc()
            .toIso8601String(),
        reminderTime: reminderDateTime.toUtc().toIso8601String(),
      );
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Reminder Created Successfully",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Set Reminder",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            ...reminderOptions.map((minutes) {
              return RadioListTile<int>(
                value: minutes,
                groupValue: selectedMinutes,
                activeColor: Colors.cyanAccent,
                title: Text(
                  getLabel(minutes),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedMinutes = value!;
                  });
                },
              );
            }),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : saveReminder,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                  "Save Reminder",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}