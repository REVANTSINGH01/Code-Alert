  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';

  
  class ApiService {
  
    // Android Emulator URL
    static const String baseUrl = "http://192.168.1.158:8000";
  
  
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
  
      if (response.statusCode==200 || response.statusCode == 201) {
  
        final prefs =
        await SharedPreferences
            .getInstance();
        await prefs.setString(
          "access_token",
          data["tokens"]["access_token"],
        );
        await prefs.setString(
          "refresh_token",
          data["tokens"]["refresh_token"],
        );
        await prefs.setString(
          "user_id",
          data["user"]["id"],
        );
        await prefs.setString(
          "username",
          data["user"]["name"],
        );
  
        await prefs.setBool("is_admin", data["user"]["is_admin"] ?? false);
  
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
        Uri.parse("$baseUrl/login",),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 15,),);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode==201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", data["tokens"]["access_token"],);
        await prefs.setString("refresh_token", data["tokens"]["refresh_token"],);
        final user = data["user"];
        await prefs.setString("user_id",user["id"],);
        await prefs.setString("username", user["name"],);
        await prefs.setBool("is_admin",user["is_admin"] ?? false,);
        return data;
      }
      throw Exception(data["detail"] ?? "Login Failed",);
    }
  
    // =========================
    // GET CONTESTS
    // =========================
  
    static Future<List<dynamic>> getContests() async {
      final response = await http.get(Uri.parse("$baseUrl/contests"),);
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
          "access_token"
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
        Uri.parse("$baseUrl/handles"),
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
  
      final data = jsonDecode(response.body);

      if(response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }
      throw Exception(
          data["detail"]
      );
    }
  
    // =========================
    // GET REMINDERS
    // =========================

    static Future<bool> refreshAccessToken() async{
      final prefs=await SharedPreferences.getInstance();
      final refreshToken=prefs.getString("refresh_token");
      if(refreshToken==null) {
        return false;
      }
      final response=await http.post(
        Uri.parse("$baseUrl/auth/refresh"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "refresh_token": refreshToken,
        }),
      );
      if(response.statusCode==200){
        final data=jsonDecode(response.body);
        await prefs.setString("access_token", data["access_token"]);
        await prefs.setString("refresh_token", data["refresh_token"]);
        return true;
      }
      await prefs.clear();
      return false;

    }

    static Future<List<dynamic>> getReminders() async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("$baseUrl/reminders/"),

        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load reminders: ${response.body}");
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

    static Future<Map<String,dynamic>> syncDashboard() async {
      final prefs = await SharedPreferences.getInstance();
      String? token =prefs.getString("token");
      print(token);
      if(token==null) {
        throw Exception(
          "Login Required"
        );
      }
      final response =
      await http.post(
          Uri.parse(
              "$baseUrl/dashboard/sync/"
          ),
          headers:{
  
            "Authorization":
            "Bearer $token",
          },
      ).timeout(const Duration(seconds: 15),);
      print(response.statusCode);
      print(response.body);
      if(response.statusCode==401){
        await prefs.clear();
        throw Exception("Session_Expired");
      }
      final data = jsonDecode(response.body);
      if(response.statusCode == 200){
        return data;
      }
      throw Exception(
          data["detail"]
      );
    }

    static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["detail"] ?? "Failed to send reset code");
      }
    }

    static Future<String> verifyOtp({required String email, required String otp}) async {
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return the reset token so the next screen can use it!
        return data["access_token"];
      } else {
        throw Exception(data["detail"] ?? "Invalid OTP");
      }
    }

    static Future<Map<String, dynamic>> resetPassword({required String token, required String newPassword}) async {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token, "new_password": newPassword}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["detail"] ?? "Failed to reset password");
      }
    }
  }