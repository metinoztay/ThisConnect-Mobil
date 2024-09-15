import 'package:flutter/material.dart';
import 'package:thisconnect/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  final Message message;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final isMe = message.senderUserId == currentUserId;

    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    final color = isMe ? Colors.green : Colors.blue;

    final textColor = Colors.white;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: size.width * 0.66),
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
