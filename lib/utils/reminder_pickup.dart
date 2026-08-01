import 'package:flutter/material.dart';
import '../services/api_service.dart';

Future<bool> pickReminderTime({
  required BuildContext context,
  required Map contest,
  bool isEdit = false,
  String? reminderId,
  DateTime? currentReminderTime,
}) async {
  final contestStart = DateTime.parse(contest["start_time"]);

  final initialTime = TimeOfDay.fromDateTime(
    currentReminderTime ??
        contestStart.subtract(const Duration(minutes: 15)),
  );

  final picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (picked == null) return false;

  final reminderTime = DateTime(
    contestStart.year,
    contestStart.month,
    contestStart.day,
    picked.hour,
    picked.minute,
  );

  if (reminderTime.isAfter(contestStart)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reminder must be before contest starts."),
        ),
      );
    }
    return false;
  }

  try {
    if (isEdit) {
      await ApiService.updateReminder(
        id: reminderId!,
        reminderTime: reminderTime,
      );
    } else {
      await ApiService.createReminder(
        contestName: contest["name"],
        contestStart: contestStart.toUtc().toIso8601String(),
        reminderTime: reminderTime.toUtc().toIso8601String(),
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? "Reminder Updated Successfully"
                : "Reminder Created Successfully",
          ),
        ),
      );
    }

    return true;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
    return false;
  }
}