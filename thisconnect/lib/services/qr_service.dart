import 'dart:convert';

import 'package:thisconnect/models/qr_model.dart';
import 'package:http/http.dart' as http;
import 'package:thisconnect/services/user_service.dart';

class QrService {
  static const String baseUrl = "http://thisconnect.runasp.net/api";
  static Future<QR> getQRInformation(String qrId) async {
    String url = "$baseUrl/QR/GetQRByID/$qrId";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    final user = await UserService.getUserInformation(json["userId"]);

    return QR(
        qrId: qrId,
        userId: json["userId"],
        title: json["title"],
        shareEmail: json["shareEmail"],
        sharePhone: json["sharePhone"],
        shareNote: json["shareNote"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        note: json["note"],
        isActive: json["isActive"],
        user: user);
  }

  static Future<bool> updateQRInformation(QR updatedQR) async {
    String url = "$baseUrl/QR/UpdateQR/${updatedQR.qrId}";
    Uri uri = Uri.parse(url);

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'qrId': updatedQR.qrId,
        'userId': updatedQR.userId,
        'title': updatedQR.title,
        'shareEmail': updatedQR.shareEmail,
        'sharePhone': updatedQR.sharePhone,
        'shareNote': updatedQR.shareNote,
        'createdAt': updatedQR.createdAt,
        'updatedAt': updatedQR.updatedAt,
        'note': updatedQR.note,
        'isActive': updatedQR.isActive,
      }),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      print('Failed to update QR information: ${response.statusCode}');
      return false;
    }
  }

  static Future<bool> deleteQR(String qrId) async {
    String url = "$baseUrl/QR/DeleteQR/$qrId";
    Uri uri = Uri.parse(url);

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        print('Failed to delete QR: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting QR: $e');
      return false;
    }
  }

  static Future<bool> addQR(QR addedQR) async {
    String url = "$baseUrl/QR/AddQR";
    Uri uri = Uri.parse(url);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'qrId': addedQR.qrId,
        'userId': addedQR.userId,
        'title': addedQR.title,
        'shareEmail': addedQR.shareEmail,
        'sharePhone': addedQR.sharePhone,
        'shareNote': addedQR.shareNote,
        'createdAt': addedQR.createdAt,
        'updatedAt': addedQR.updatedAt,
        'note': addedQR.note,
        'isActive': addedQR.isActive,
      }),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      print('Failed to add QR: ${response.statusCode}');
      return false;
    }
  }

  static Future<List<QR>?> getUsersQRList(String userId) async {
    String url = "$baseUrl/QR/GetQRsByUserID/$userId";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    final results = json['\$values'] as List<dynamic>;
    final user;
    try {
      user = await UserService.getUserInformation(results[0]["userId"]);
    } catch (e) {
      return null;
    }

    final qrlist = await Future.wait(results.map((e) async {
      return QR(
          qrId: e["qrId"],
          userId: e["userId"],
          title: e["title"],
          shareEmail: e["shareEmail"],
          sharePhone: e["sharePhone"],
          shareNote: e["shareNote"],
          note: e["note"],
          createdAt: e["createdAt"],
          updatedAt: e["updatedAt"],
          isActive: e["isActive"],
          user: user);
    }));
    return qrlist;
  }
}
