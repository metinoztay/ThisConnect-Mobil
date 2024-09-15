import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thisconnect/models/otp_model.dart';
import 'package:thisconnect/models/user_model.dart';

class OtpService {
  static const String baseUrl = "http://thisconnect.runasp.net/api";
  static Future<void> createOtpRequest(String phone) async {
    String url = "$baseUrl/OTP/CreateOTP?phone=$phone";
    Uri uri = Uri.parse(url);
    await http.post(uri);
  }

  static Future<User?> otpVerification(Otp otp) async {
    String url = "$baseUrl/OTP/OTPVerification";
    Uri uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'phone': otp.phone,
          'otpValue': otp.otpValue,
        }),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return User(
          userId: jsonData['userId'],
          phone: jsonData['phone'],
          email: jsonData['email'],
          title: jsonData['title'],
          name: jsonData['name'],
          surname: jsonData['surname'],
          avatarUrl: jsonData['avatarUrl'],
          lastSeenAt: jsonData['lastSeenAt'],
        );
      } else {
        print('Failed to verify OTP: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return null;
    }
  }
}
