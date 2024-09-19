import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:open_file/open_file.dart';
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
                    FutureBuilder<IconData>(
                        future: _getFileIcon(e.attachmentId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Icon(snapshot.data);
                          } else {
                            return Container();
                          }
                        }),
                    SizedBox(width: 8),
                    Text(
                      e.content,
                      style: TextStyle(color: textColor),
                    ),
                    SizedBox(width: 8),
                    FutureBuilder<String>(
                        future: getFileName(e.attachmentId!),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return InkWell(
                              onTap: () async {
                                try {
                                  File? file = await UploadService.downloadFile(
                                      e.attachmentId!);
                                  if (_isAudioFile(file!.path)) {
                                    // Oynatıcıyı başlatmak için bir metod çağırın
                                    playAudio(file);
                                  } else {
                                    OpenFile.open(file.path);
                                  }
                                } on Exception catch (e) {
                                  print('Error downloading file: $e');
                                }
                              },
                              child: snapshot.data != null
                                  ? _isAudioFile(snapshot.data)
                                      ? Icon(Icons.play_arrow)
                                      : Icon(Icons.download)
                                  : CircularProgressIndicator(),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
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

File? selectedFile;
FlutterSoundPlayer? _player;
bool _isRecording = false;
bool _isPlaying = false;
String? _recordedFilePath;
int _recordDuration = 0;
Duration _currentPosition = Duration();
Duration _audioDuration = Duration();
StreamSubscription? _progressSubscription;

Future<void> _openPlayer() async {
  await _player!.openPlayer();
  _player!.setSubscriptionDuration(Duration(milliseconds: 10));
}

Future<void> playAudio(File audio) async {
  _player = FlutterSoundPlayer();
  if (_player!.isStopped) {
    await _openPlayer();

    _progressSubscription = _player!.onProgress!.listen((event) {});

    await _player!.startPlayer(
      fromURI: audio.path,
      codec: Codec.aacADTS,
      whenFinished: () {
        _progressSubscription?.cancel();
      },
    );
  } else {
    stopPlaying();
  }
}

Future<void> stopPlaying() async {
  if (_isPlaying) {
    await _player!.stopPlayer();

    _progressSubscription?.cancel();
    _currentPosition = Duration();
    _audioDuration = Duration();
  }
}

Future<IconData> _getFileIcon(String attachmentId) async {
  Attachment attach = await UploadService.getAttachmentById(attachmentId);
  final fileExtension = attach.fileName.split('.').last.toLowerCase();
  if (fileExtension == 'aac') {
    return Icons.audiotrack;
  }
  return Icons.insert_drive_file;
}

bool _isAudioFile(String? fileName) {
  if (fileName != null) {
    final fileExtension = fileName.split('.').last.toLowerCase();
    return fileExtension == 'aac';
  }
  return false;
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
