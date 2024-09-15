import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thisconnect/models/attachment_model.dart';
import 'package:thisconnect/models/message_model.dart';
import 'package:thisconnect/services/upload_service.dart';

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

  return Column(
    crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Align(
        alignment: alignment,
        child: Container(
          constraints: BoxConstraints(maxWidth: size.width * 0.66),
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: e.attachmentId != null
              ? Row(
                  children: [
                    Icon(Icons.insert_drive_file),
                    SizedBox(width: 8),
                    Text(
                      e.content,
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(width: 8),
                    e.attachmentId != null
                        ? FutureBuilder<String>(
                            future: getFileName(e.attachmentId!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return InkWell(
                                  onTap: () async {
                                    try {
                                      await UploadService.downloadFile(
                                          e.attachmentId!);
                                    } on Exception catch (e) {
                                      print('Error downloading file: $e');
                                    }
                                  },
                                  child: snapshot.hasData
                                      ? Icon(Icons.download)
                                      : CircularProgressIndicator(),
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            })
                        : Container(),
                  ],
                )
              : Text(
                  e.content,
                  style: TextStyle(color: textColor),
                ),
        ),
      ),
    ],
  );
}

Future<String> getFileName(String attachmentId) async {
  final Attachment filename =
      await UploadService.getAttachmentById(attachmentId);
  return filename.fileName;
}

Widget messageTime(bool isMyChat, Message e) {
  var parsedDate = DateTime.parse(e.createdAt);
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
