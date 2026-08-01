import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils./reminder_pickup.dart';

Future<bool?> showReminderBottomSheet({
  required BuildContext context,
  required Map contest,
  bool isEdit = false,
  String? reminderId,
  DateTime? currentReminderTime,
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
      isEdit: isEdit,
      reminderId: reminderId,
      currentReminderTime: currentReminderTime,
    ),
  );
}

class ReminderBottomSheet extends StatefulWidget {
  final Map contest;
  final bool isEdit;
  final String? reminderId;
  final DateTime? currentReminderTime;

  const ReminderBottomSheet({
    super.key,
    required this.contest,
    this.isEdit = false,
    this.reminderId,
    this.currentReminderTime,
  });

  @override
  State<ReminderBottomSheet> createState() =>
      _ReminderBottomSheetState();
}

class _ReminderBottomSheetState
    extends State<ReminderBottomSheet> {

  bool isLoading = false;


  late DateTime selectedReminderTime;

  @override
  void initState() {
    super.initState();

    final contestStart =
    DateTime.parse(widget.contest["start_time"]);

    if (widget.isEdit &&
        widget.currentReminderTime != null) {
      selectedReminderTime =
      widget.currentReminderTime!;
    } else {
      selectedReminderTime =
          contestStart.subtract(
            const Duration(minutes: 15),
          );
    }
  }

  Future<void> pickReminderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedReminderTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked == null) return;

    setState(() {
      selectedReminderTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        selectedReminderTime.hour,
        selectedReminderTime.minute,
      );
    });
  }

  Future<void> pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        selectedReminderTime,
      ),
    );

    if (picked == null) return;

    setState(() {
      selectedReminderTime = DateTime(
        selectedReminderTime.year,
        selectedReminderTime.month,
        selectedReminderTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> saveReminder() async {
    setState(() {
      isLoading = true;
    });

    try {
      final contestStartTime = DateTime.parse(
        widget.contest["start_time"],
      );

      final reminderDateTime =selectedReminderTime;

      if (widget.isEdit) {
        await ApiService.updateReminder(
          id: widget.reminderId!,
          reminderTime: reminderDateTime,
        );
      } else {
        await ApiService.createReminder(
          contestName: widget.contest["name"],
          contestStart: contestStartTime.toUtc().toIso8601String(),
          reminderTime: reminderDateTime.toUtc().toIso8601String(),
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? "Reminder Updated Successfully"
                : "Reminder Created Successfully",
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

            Text(
              widget.isEdit
                  ? "Edit Reminder"
                  : "Set Reminder",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF262637),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Contest",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.contest["name"],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.contest["start_time"],
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Card(
              color: const Color(0xFF262637),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.cyanAccent,
                    ),
                    title: const Text(
                      "Reminder Date",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      "${selectedReminderTime.day}/${selectedReminderTime.month}/${selectedReminderTime.year}",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: pickReminderDate,
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.access_time,
                      color: Colors.cyanAccent,
                    ),
                    title: const Text(
                      "Reminder Time",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      TimeOfDay.fromDateTime(
                        selectedReminderTime,
                      ).format(context),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: pickReminderTime,
                  ),
                ],
              ),
            ),

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
                    : Text(
                  widget.isEdit
                      ? "Update Reminder"
                      : "Save Reminder",
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}