class Message {
  String? messageId;
  String chatRoomId;
  String senderUserId;
  String recieverUserId;
  String? attachmentId;
  String content;
  String createdAt;
  String? readedAt;

  Message({
    this.messageId,
    required this.chatRoomId,
    required this.senderUserId,
    required this.recieverUserId,
    this.attachmentId,
    required this.content,
    required this.createdAt,
    this.readedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'],
      chatRoomId: json['chatRoomId'],
      senderUserId: json['senderUserId'],
      recieverUserId: json['recieverUserId'],
      attachmentId: json['attachmentId'],
      content: json['content'],
      createdAt: json['createdAt'],
      readedAt: json['readedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'chatRoomId': chatRoomId,
      'senderUserId': senderUserId,
      'recieverUserId': recieverUserId,
      'attachmentId': attachmentId,
      'content': content,
      'createdAt': createdAt,
      'readedAt': readedAt,
    };
  }
}
