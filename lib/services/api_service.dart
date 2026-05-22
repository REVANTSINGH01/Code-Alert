import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // Android Emulator URL
  static const String baseUrl = "http://192.168.45.182:8000";


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

      final prefs =
      await SharedPreferences
          .getInstance();
      await prefs.setString(
        "token",
        data["access_token"],
      );
      await prefs.setString(
        "user_id",
        data["user"]["id"],
      );
      await prefs.setString(
        "username",
        data["user"]["name"],
      );
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
      final prefs =
      await SharedPreferences
          .getInstance();
      await prefs.setString(
        "token",
        data["access_token"],
      );
      await prefs.setString(
        "user_id",
        data["user"]["id"],
      );
      await prefs.setString(
        "username",
        data["user"]["name"],
      );
      return data;
    } else {
      throw Exception(data["detail"]);
    }
  }

  // =========================
  // GET CONTESTS
  // =========================

  static Future<List<dynamic>>
  getContests()
  async {
    final response =
    await http.get(
      Uri.parse("$baseUrl/contests"),
    );
    if(response.statusCode == 200){
      return jsonDecode(
          response.body
      );
    }
    throw Exception(
        "Failed to load contests"
    );

  }

  // =========================
  // UPDATE HANDLES
  // =========================

  static Future<Map<String,dynamic>> updateHandles({String? cfHandle, String? lcHandle, String? ccHandle,}) async {
    final prefs = await SharedPreferences.getInstance();
    String? token =
    prefs.getString(
        "token"
    );
    if(token == null){
      throw Exception(
          "Login required"
      );
    }
    Map<String,dynamic>
    body = {};
    if(cfHandle != null && cfHandle.isNotEmpty){
      body["cf_handle"] =
          cfHandle;
    }
    if(lcHandle != null && lcHandle.isNotEmpty){
      body["lc_handle"] = lcHandle;
    }
    if(
    ccHandle != null && ccHandle.isNotEmpty){
      body["cc_handle"]=ccHandle;
    }
    final response = await http.put(
      Uri.parse("$baseUrl/users/handles"),
      headers:{
        "Content-Type":
        "application/json",
        "Authorization":
        "Bearer $token"
      },
      body:

      jsonEncode(
          body
      ),

    );

    final data =

    jsonDecode(
        response.body
    );

    print(data);

    if(
    response.statusCode
        ==
        200
    ){

      return data;

    }

    throw Exception(
        data["detail"]
    );
  }

  // =========================
  // GET REMINDERS
  // =========================

  static Future<List<dynamic>> getReminders() async {
    final response = await http.get(
      Uri.parse("$baseUrl/reminders/"),
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
  static Future<Map<String,dynamic>>
  syncDashboard()
  async {

    final prefs =
    await SharedPreferences
        .getInstance();

    String? token =prefs.getString("token");
    print(token);
    if(token==null) {
      throw Exception(
        "Login Reuqired"
      );
    }
    final response =
    await http.post(
        Uri.parse(
            "$baseUrl/dashboard/sync/"
        ),
        headers:{

          "Authorization":
          "Bearer $token"
        }
    );
    print(response.statusCode);
    print(response.body);

    final data =
    jsonDecode(
        response.body
    );

    if(
    response.statusCode
        ==
        200
    ){

      return data;

    }

    throw Exception(
        data["detail"]
    );
  }
  
}