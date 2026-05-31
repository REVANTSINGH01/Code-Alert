import 'package:flutter/material.dart';

// 📅 Helper functions moved here so they don't clutter the homepage
String _formatDate(String isoString) {
  try {
    DateTime date = DateTime.parse(isoString);
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  } catch (e) {
    return "Unknown Date";
  }
}

String _formatTime(String isoString) {
  try {
    DateTime date = DateTime.parse(isoString);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  } catch (e) {
    return "--:--";
  }
}

// 🚀 Public function to show the bottom sheet (Removed the '_')
void showContestDetails(BuildContext context, Map contest, Color textColor) {
  // 🎨 Deep blue-grey colors to match your screenshot
  final bgColor = const Color(0xFF1E1E28); // Background of the modal
  final cardColor = const Color(0xFF252532); // Inner boxes
  final primaryBlue = const Color(0xFFA0B4FF); // The soft "Register Now" blue

  final String platform = (contest["platform"] ?? "UNKNOWN").toString().toUpperCase();
  final String title = contest["name"] ?? "Contest Name";
  final String startDate = _formatDate(contest["start_time"] ?? "");
  final String startTime = _formatTime(contest["start_time"] ?? "");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows it to be taller if needed
    backgroundColor: Colors.transparent, // Transparent so we can see our custom rounded corners
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Hugs the content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔷 Top Row: Platform & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.code, color: Colors.cyanAccent, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "$platform PLATFORM",
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 🔷 Title
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 24),

            // 🔷 Date & Time Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DATE", style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(startDate, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("START TIME", style: TextStyle(color: textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("$startTime UTC", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔷 About Section
            Text(
              "About this Contest",
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              contest["description"] ?? "Standard competitive programming round. Features multiple algorithmic problems and a strict time limit. Rated for all participants.",
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // 🔷 Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: const Color(0xFF121212),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Register Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: textColor.withValues(alpha: 0.2), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.notifications_none),
                label: const Text("Set Reminder", style: TextStyle(fontSize: 16)),
                onPressed: () {
                  // TODO: Call your ApiService.createReminder here!
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}