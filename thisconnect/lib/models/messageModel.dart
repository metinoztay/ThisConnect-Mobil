import 'dart:convert';

class MessageModel {
  String? userId;
  String? userName;
  String? messageText;
  String? createDate;

  MessageModel({
    this.userId,
    this.userName,
    this.messageText,
    this.createDate,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    userId = json["userId"]?.toString();
    userName = json["userName"]?.toString();
    messageText = json["messageText"]?.toString();
    createDate = json["createDate"]?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'messageText': messageText,
      'createDate': createDate,
    };
  }

  @override
  String toString() {
    return json.encode(toJson());
  }
}
