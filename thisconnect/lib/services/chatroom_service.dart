import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thisconnect/models/chatroom_model.dart';

class ChatroomService {
  static const String baseUrl = "http://thisconnect.runasp.net/api";
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
}
