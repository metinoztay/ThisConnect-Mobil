import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thisconnect/models/message_model.dart';

class MessageService {
  static const String baseUrl = "http://thisconnect.runasp.net/api";
  static Future<List<Message>?> getMessagesByChatRoomId(
      String chatRoomId) async {
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
