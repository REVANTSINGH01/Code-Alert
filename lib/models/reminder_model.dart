class Reminder {
  final String id;
  final String contestName;
  final DateTime contestStart;
  final DateTime reminderTime;

  const Reminder({
    required this.id,
    required this.contestName,
    required this.contestStart,
    required this.reminderTime,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json["id"],
      contestName: json["contest_name"],
      contestStart: DateTime.parse(json["contest_start"]),
      reminderTime: DateTime.parse(json["reminder_time"]),
    );
  }
}