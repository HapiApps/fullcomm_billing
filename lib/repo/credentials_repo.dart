import 'dart:convert';
import 'dart:developer';

import 'package:fullcomm_billing/api/api_urls.dart';

import '../data/project_data.dart';
import '../models/check_privacy_response.dart';
import '../models/user_response.dart';
import 'package:http/http.dart' as http;

class CredentialsRepository {
  /// -------------- User Login ----------------
  Future<UserDataResponse> loginApi(
      {required String mobile, required String password}) async {
    final response = await http.post(
      Uri.parse(ApiUrl.script),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
          {"mobile": mobile, "password": password, "action": "b_login"}),
    );

    // log("Status Code: ${{
    //     "mobile": mobile,
    //     "password": password,
    //     "action": "b_login",
    //     "cos_id":ProjectData.cosId
    //     }}");
    log("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return UserDataResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Login Error : ${response.body}");
    }
  }

  Future<LoginResponse> checkPrivacy(String mobile, String password) async {
    final response = await http.post(
      Uri.parse(ApiUrl.script),
      body: {
        'mobile': mobile,
        'password': password,
        "action": "e_check_privacy_policy",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return LoginResponse.fromJson(data);
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<LoginResponse> privacyPolicy(String mobile, String password) async {
    // You’re sending JSON to your PHP code
    final response = await http.post(
      Uri.parse(ApiUrl.script),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobile': mobile,
        'password': password,
        "action": "e_privacy_policy",
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return LoginResponse.fromJson(data);
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> checkVersion() async {
    final data = {
      "search_type": "checkVersion",
      "action": "e_check_version",
    };

    final response = await http.post(
      Uri.parse(ApiUrl.script),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      if (decoded.isNotEmpty) {
        return decoded[0] as Map<String, dynamic>;
      }
    }
    return null;
  }
}
