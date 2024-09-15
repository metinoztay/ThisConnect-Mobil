import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/services/user_service.dart';

class PrefService {
  static Future<bool> savePrefUserInformation(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()).toString());
    return true;
  }

  static Future<User?> getPrefUserInformation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user');
    if (json != null) {
      return User.fromJson(jsonDecode(json));
    } else {
      return null;
    }
  }

  static Future<bool> removePrefUserInformation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    return true;
  }

  static Future<bool> updatePrefUserInformation(String userId) async {
    final User user = await UserService.getUserInformation(userId);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()).toString());
    return true;
  }
}
