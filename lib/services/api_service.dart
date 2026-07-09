  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';

  
  class ApiService {
  
    // Android Emulator URL
    static const String baseUrl = "http://192.168.29.61:8000";
  
  
    static Future<Map<String, dynamic>> signup({
      required String name,
      required String email,
      required String password,
    }) async {
      Map<String,dynamic> body={};
      body["name"]=name;
      body["email"]=email;
      body["password"]=password;
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));
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
      }
        throw Exception(data["detail"]);
    }
  
    // =========================
    // LOGIN
    // =========================
  
    static Future<Map<String, dynamic>> login({
      required String email,
      required String password,
    }) async {
      Map<String,dynamic> body={};
      body["email"]=email;
      body["password"]=password;
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));
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
      final response = await authenticatedRequest(method: "GET", url:"$baseUrl/contests",);
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
      Map<String,dynamic>body = {};
      if(cfHandle != null && cfHandle.isNotEmpty){
        body["cf_handle"] = cfHandle;
      }
      if(lcHandle != null && lcHandle.isNotEmpty){
        body["lc_handle"] = lcHandle;
      }
      if(
      ccHandle != null && ccHandle.isNotEmpty){
        body["cc_handle"]=ccHandle;
      }
      final response = await authenticatedRequest(method: "PUT", url: "$baseUrl/handles",body:body,);
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

      final response = await authenticatedRequest(method: "GET",url:"$baseUrl/reminders/",);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load reminders: ${response.body}");
      }
    }

    static Future<http.Response> authenticatedRequest({
      required String method,
      required String url,
      Map<String,dynamic>? body,
  }) async{
      final prefs=await SharedPreferences.getInstance();
      String? accessToken=prefs.getString("access_token");
      if(accessToken==null){
        throw Exception("Login required");
      }
      Future<http.Response> sendRequest(String token){
        final headers={
          "Content-Type": "application/json",
          "Authorization" : "Bearer $token",
        };
        switch (method.toUpperCase()){
          case "GET":
            return http.get(
              Uri.parse(url),
              headers: headers,
            );
          case "POST":
            return http.post(
              Uri.parse(url),
              headers: headers,
              body: body==null ? null: jsonEncode(body),
            );
          case "PUT":
            return http.put(
              Uri.parse(url),
              headers: headers,
              body: body==null ? null: jsonEncode(body),
            );
          case "PATCH":
            return http.patch(
              Uri.parse(url),
              headers: headers,
              body: body == null ? null : jsonEncode(body),
            );
          case "DELETE":
            return http.delete(
              Uri.parse(url),
              headers: headers,
            );
          default:
            throw Exception("Unsupported HTTP method");
        }
      }
      var response= await sendRequest(accessToken);
      if(response.statusCode==401){
        final refreshed=await refreshAccessToken();
        if(!refreshed){
          throw Exception("Session Expired");
        }
        accessToken= prefs.getString("access_token");
        response =await sendRequest(accessToken!);
      }
      return response;
    }
  
    // =========================
    // CREATE REMINDER
    // =========================
  
    static Future<Map<String, dynamic>> createReminder({
      required String userId,
      required String contestName,
      required String reminderTime,
    }) async {
      Map<String,dynamic> body={};
      body["user_id"]=userId;
      body["contest_name"]=contestName;
      body["reminder_time"]=reminderTime;
      final response = await authenticatedRequest(method: "POST", url:"$baseUrl/reminder",body:body,);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["detail"]);
      }
    }

    static Future<Map<String, dynamic>> syncDashboard() async {
      final response = await authenticatedRequest(
        method: "POST",
        url: "$baseUrl/dashboard/sync/",
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print("syncDashboard() called");
        return data;
      }
      throw Exception(
        data["detail"] ?? "Dashboard Sync Failed",
      );
    }

    static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
      Map<String,dynamic> body={};
      body["email"]=email;
      final response = await http.post(
        Uri.parse("$baseUrl/forgot-password"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["detail"] ?? "Failed to send reset code");
      }
    }

    static Future<String> verifyOtp({required String email, required String otp}) async {
      Map<String,dynamic> body={};
      body["email"]=email;
      body["otp"]=otp;
      final response = await http.post(
        Uri.parse("$baseUrl/verify-otp"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
       return data["access_token"];
      } else {
        throw Exception(data["detail"] ?? "Invalid OTP");
      }
    }
    static Future<Map<String, dynamic>> resetPassword({required String token, required String newPassword}) async {
      Map<String,dynamic> body={};
      body["token"]=token;
      body["new_password"]=newPassword;
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data["detail"] ?? "Failed to reset password");
      }
    }
  }