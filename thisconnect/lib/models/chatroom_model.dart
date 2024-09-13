class ChatRoom {
  final String chatRoomId;
  final String participant1Id;
  final String participant2Id;
  final String? lastMessageId;
  final String createdAt;

  const ChatRoom({
    required this.chatRoomId,
    required this.participant1Id,
    required this.participant2Id,
    this.lastMessageId,
    required this.createdAt,
  });
}
