import 'dart:convert';
import 'package:thisconnect/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:thisconnect/services/pref_service.dart';

class UserService {
  static const String baseUrl = "http://thisconnect.runasp.net/api";

  static Future<void> createUser(User user) async {
    String url = "$baseUrl/User/CreateUser";
    Uri uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var result = User(
          userId: json['userId'],
          phone: json['phone'],
          email: json['email'],
          title: json['title'],
          name: json['name'],
          surname: json['surname'],
          avatarUrl: json['avatarUrl'],
          lastSeenAt: json['lastSeenAt'],
        );

        await PrefService.savePrefUserInformation(result);
      } else if (response.statusCode == 404) {
        print('No chat room found for these participants.');
        return null;
      } else {
        print('Failed to find chat room: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error finding chat room: $e');
      return null;
    }
  }

  static Future<User> getUserInformation(String userId) async {
    String url = "$baseUrl/User/GetUserById/$userId";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    return User(
        userId: json["userId"],
        phone: json["phone"],
        email: json["email"],
        title: json["title"],
        name: json["name"],
        surname: json["surname"],
        avatarUrl: json["avatarUrl"],
        lastSeenAt: json["lastSeenAt"]);
  }

  static Future<void> updateLastSeenAt(String userId) async {
    String url = "$baseUrl/User/UpdateLastSeenAt?userId=$userId";
    Uri uri = Uri.parse(url);
    await http.put(uri);
  }
}
