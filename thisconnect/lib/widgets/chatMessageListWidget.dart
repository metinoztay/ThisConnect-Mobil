import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thisconnect/models/messageModel.dart';
import 'package:thisconnect/models/message_model.dart';

Widget chatMessageWidget(ScrollController chatListScrollController,
    List<Message> message, String currentUserId, BuildContext context) {
  return Expanded(
      child: Container(
    color: Colors.white,
    child: SingleChildScrollView(
      controller: chatListScrollController,
      child: Column(
        children: [
          ...message.map((e) => chatItemWidget(e, currentUserId, context)),
          SizedBox(
            height: 6,
          )
        ],
      ),
    ),
  ));
}

Widget chatItemWidget(Message e, String currentUserId, BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isMe = e.senderUserId == currentUserId;

  final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

  final color = isMe ? Colors.green : Colors.blue;

  final textColor = Colors.white;
  bool isMyChat = e.senderUserId == currentUserId;
  return e.senderUserId == 0
      ? systemMessageWidget(e.content!)
      : Align(
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
              e.content ?? '',
              style: TextStyle(color: textColor),
            ),
          ),
        );
}

Widget systemMessageWidget(String text) {
  return Container(
    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
    margin: EdgeInsets.only(top: 8),
    decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.all(Radius.circular(25))),
    child: Text(
      text,
      style: TextStyle(color: Colors.grey, fontSize: 12),
    ),
  );
}

Widget userAvatar(int userId, String userName) {
  Color avatarColor = Colors.greenAccent;
  if (userId < 10000) {
    avatarColor = Color(0xFFffadad);
  } else if (userId < 100000) {
    avatarColor = Color(0xFFffd6a5);
  } else if (userId < 200000) {
    avatarColor = Color(0xFFfdffb6);
  } else if (userId < 700000) {
    avatarColor = Color(0xFFcaffbf);
  } else if (userId < 1000000) {
    avatarColor = Colors.blueAccent;
  }

  return Container(
    width: 40,
    height: 40,
    margin: EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(shape: BoxShape.circle, color: avatarColor),
    child: Center(
      child: Text(
        userName.substring(0, 1).toUpperCase(),
        style: TextStyle(
            fontFamily: "Lobster", fontSize: 18, color: Colors.black87),
      ),
    ),
  );
}

Widget messageTextAndName(bool isMyChat, String messageText, String userName) {
  return Expanded(
      child: Column(
    crossAxisAlignment:
        isMyChat ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Container(
        margin: EdgeInsets.fromLTRB(isMyChat ? 20 : 8, 6, 8, 6),
        padding: EdgeInsets.fromLTRB(16, isMyChat ? 6 : 14, 16, 12),
        decoration: BoxDecoration(
            color: isMyChat ? Color(0xffebebeb0) : Color(0xffedf4ff),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMyChat)
              Text(
                userName,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            Text(
              messageText,
              style: TextStyle(height: 1.7),
            ),
          ],
        ),
      ),
    ],
  ));
}

Widget messageTime(bool isMyChat, MessageModel e) {
  var parsedDate = DateTime.parse(e.createDate!);
  var timeText =
      "${parsedDate.hour} : ${parsedDate.minute.toString().padLeft(2, '0')}";
  return Container(
      margin: EdgeInsets.only(
          left: isMyChat ? 48 : 8, bottom: 12, right: isMyChat ? 0 : 16),
      alignment: Alignment.center,
      child: Text(
        timeText,
        style: const TextStyle(color: Colors.grey),
      ));
}
