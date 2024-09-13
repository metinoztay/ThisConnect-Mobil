import 'dart:convert';
import 'package:thisconnect/models/chatroom_model.dart';
import 'package:thisconnect/models/message_model.dart';
import 'package:thisconnect/models/otp_model.dart';
import 'package:thisconnect/models/qr_model.dart';
import 'package:http/http.dart' as http;
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/services/pref_handler.dart';

class ApiHandler {
  static const String baseUrl = "http://thisconnect.runasp.net/api";
  static Future<QR> getQRInformation(String qrId) async {
    String url = "$baseUrl/QR/GetQRByID/$qrId";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    final user = await getUserInformation(json["userId"]);

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
    final response = await http.put(uri);
  }

  static Future<void> createOtpRequest(String phone) async {
    String url = "$baseUrl/OTP/CreateOTP?phone=$phone";
    Uri uri = Uri.parse(url);
    final response = await http.post(uri);
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

  static Future<List<QR>?> getUsersQRList(String userId) async {
    String url = "$baseUrl/QR/GetQRsByUserID/$userId";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    final results = json['\$values'] as List<dynamic>;
    final user;
    try {
      user = await getUserInformation(results[0]["userId"]);
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

  static Future<bool> createChatRoom(ChatRoom chatRoom) async {
    String url = "$baseUrl/ChatRoom/CreateChatRoom";
    Uri uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'chatRoomId': "",
          'participant1Id': chatRoom.participant1Id,
          'participant2Id': chatRoom.participant2Id,
          'lastMessageId': null,
          'createdAt': "",
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create chat room: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error creating chat room: $e');
      return false;
    }
  }

  static Future<ChatRoom?> findChatRoom(ChatRoom chatRoom) async {
    String url = "$baseUrl/ChatRoom/FindChatRoom";
    Uri uri = Uri.parse(url);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'chatRoomId': "",
          'lastMessageId': "",
          'createdAt': "",
          'participant1Id': chatRoom.participant1Id,
          'participant2Id': chatRoom.participant2Id,
        }),
      );

      if (response.statusCode == 200) {
        var result = ChatRoom(
          participant1Id: chatRoom.participant1Id,
          participant2Id: chatRoom.participant2Id,
          chatRoomId: jsonDecode(response.body)['chatRoomId'],
          lastMessageId: jsonDecode(response.body)['lastMessageId'],
          createdAt: jsonDecode(response.body)['createdAt'],
        );
        return result;
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
          lastSeenAt: json['lastSeenAt'],
        );

        await PrefHandler.savePrefUserInformation(result);
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

  static Future<List<ChatRoom>> getChatRoomsByParticipant(
      String participantId) async {
    String url =
        "$baseUrl/ChatRoom/GetChatRoomsByParticipant?participantId=$participantId";
    Uri uri = Uri.parse(url);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final results = json['\$values'] as List<dynamic>;
        final qrlist = await Future.wait(results.map((e) async {
          return ChatRoom(
            participant1Id: e["participant1Id"],
            participant2Id: e["participant2Id"],
            chatRoomId: e["chatRoomId"],
            lastMessageId: e["lastMessageId"],
            createdAt: e["createdAt"],
          );
        }));
        return qrlist;
      } else if (response.statusCode == 404) {
        print('No chat rooms found for this participant.');
        return [];
      } else {
        print('Failed to retrieve chat rooms: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error retrieving chat rooms: $e');
      return [];
    }
  }

  static Future<List<Message>?> getMessagesByChatRoomId(
      String chatRoomId) async {
    String? lastMessageId = null;
    String url =
        "$baseUrl/Messages/GetMessagesByChatRoomId?chatRoomId=$chatRoomId";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    final results = json['\$values'] as List<dynamic>;

    final messages = await Future.wait(results.map((e) async {
      return Message(
        messageId: e["messageId"],
        senderUserId: e["senderUserId"],
        recieverUserId: e["recieverUserId"],
        chatRoomId: e["chatRoomId"],
        attachmentId: e["attachmentId"],
        content: e["content"],
        createdAt: e["createdAt"],
        readedAt: e["readedAt"],
      );
    }));
    return messages;
  }

  static Future<Message> getMessageByMessageId(String messageId) async {
    String? lastMessageId = null;
    String url = "$baseUrl/Messages/GetMessageById?messageId=$messageId";
    Uri uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);

    return Message(
      messageId: json["messageId"],
      senderUserId: json["senderUserId"],
      recieverUserId: json["recieverUserId"],
      chatRoomId: json["chatRoomId"],
      attachmentId: json["attachmentId"],
      content: json["content"],
      createdAt: json["createdAt"],
      readedAt: json["readedAt"],
    );
  }
}
