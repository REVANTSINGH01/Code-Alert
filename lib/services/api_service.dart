import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  // Android Emulator URL
  static const String baseUrl = "http://192.168.1.158:8000";

  // For Physical Device:
  // static const String baseUrl = "http://192.168.X.X:8000";

  // =========================
  // SIGNUP
  // =========================

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/signup"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["detail"]);
    }
  }

  // =========================
  // LOGIN
  // =========================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["detail"]);
    }
  }

  // =========================
  // GET CONTESTS
  // =========================

  static Future<List<dynamic>> getContests() async {

    final response = await http.get(
      Uri.parse("$baseUrl/contests"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load contests");
    }
  }

  // =========================
  // UPDATE HANDLES
  // =========================

  static Future<Map<String, dynamic>> updateHandles({
    required String userId,
    String? cfHandle,
    String? lcHandle,
    String? ccHandle,
  }) async {

    final response = await http.put(
      Uri.parse("$baseUrl/users/$userId/handles"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "cf_handle": cfHandle,
        "lc_handle": lcHandle,
        "cc_handle": ccHandle,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["detail"]);
    }
  }

  // =========================
  // GET REMINDERS
  // =========================

  static Future<List<dynamic>> getReminders(
      String userId,
      ) async {

    final response = await http.get(
      Uri.parse("$baseUrl/reminders/$userId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load reminders");
    }
  }

  // =========================
  // CREATE REMINDER
  // =========================

  static Future<Map<String, dynamic>> createReminder({
    required String userId,
    required String contestName,
    required String reminderTime,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/reminder"),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode({
        "user_id": userId,
        "contest_name": contestName,
        "reminder_time": reminderTime,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["detail"]);
    }
  }

  // =========================
  // DASHBOARD SYNC
  // =========================

  static Future<Map<String, dynamic>> syncDashboard(
      String userId,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/dashboard/sync/$userId"),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["detail"]);
    }
  }
}