import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

void showContestDetails(BuildContext context, Map contest, Color homepageTextColor) {
  final bgColor = const Color(0xFF1B1B26);
  final cardColor = const Color(0xFF232332);
  final primaryBlue = const Color(0xFFAAB6FA);
  final Color modalTextColor = Colors.white;

  final String platform = (contest["platform"] ?? "UNKNOWN").toString().toUpperCase();
  final String title = contest["name"] ?? "Contest Name";
  final String startDate = _formatDate(contest["start_time"] ?? "");
  final String startTime = _formatTime(contest["start_time"] ?? "");

  showDialog(
    context: context,
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 37),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            height: screenHeight * 0.75,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: modalTextColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.code, color: Colors.cyanAccent, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "$platform PLATFORM",
                          style: TextStyle(
                            color: modalTextColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: modalTextColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),


                Text(
                  title,
                  style: TextStyle(
                    color: modalTextColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 24),


                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("DATE", style: TextStyle(color: modalTextColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(startDate, style: TextStyle(color: modalTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("START TIME", style: TextStyle(color: modalTextColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("$startTime UTC", style: TextStyle(color: modalTextColor, fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 2),
                Text(
                  "About this Contest",
                  style: TextStyle(color: modalTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  contest["description"] ?? "Standard competitive programming round. Features multiple algorithmic problems and a strict time limit. Rated for all participants.",
                  style: TextStyle(
                    color: modalTextColor.withValues(alpha: 0.8),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 3),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: const Color(0xFF121212),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      String urlString = "";
                      if (platform.toLowerCase() == "leetcode") {
                        String slug = title.toLowerCase().replaceAll(' ', '-');
                        urlString = "https://leetcode.com/contest/$slug";
                      }
                      else if (contest["url"] != null && contest["url"].toString().isNotEmpty) {
                        urlString = contest["url"];
                      }
                      else {
                        urlString = "https://www.google.com/search?q=${Uri.encodeComponent('$title $platform')}";
                      }
                      if (!urlString.startsWith("http")) {
                        urlString = "https://$urlString";
                      }
                      final Uri url = Uri.parse(urlString);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      } else {
                        debugPrint("Could not launch $urlString");
                      }
                    },
                    child: const Text("Register Now", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: modalTextColor,
                      side: BorderSide(color: modalTextColor.withValues(alpha: 0.2), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.notifications_none, size: 20),
                    label: const Text("Set Reminder", style: TextStyle(fontSize: 15)),
                    onPressed: () {
                      // Call your ApiService.createReminder here!

                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}