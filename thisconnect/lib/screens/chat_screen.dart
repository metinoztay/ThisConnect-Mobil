import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:thisconnect/models/chatroom_model.dart';
import 'package:thisconnect/models/message_model.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/services/message.service.dart';
import 'package:thisconnect/services/user_service.dart';
import 'package:thisconnect/utils/removeMessageExtraChar.dart';
import 'package:thisconnect/widgets/chatMessageListWidget.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:thisconnect/widgets/chatTypeMessageWidget.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final User user;

  const ChatScreen(this.user, this.chatRoom, {super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  User? reciever;
  ScrollController chatListScrollController = ScrollController();
  TextEditingController messageTextController = TextEditingController();

  bool isMessageEmpty = true;
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    getUserInformation();
    openSignalRConnection();
    messageTextController.addListener(_handleMessageChanged);
    getOldMessages();
  }

  @override
  void dispose() {
    messageTextController.removeListener(_handleMessageChanged);
    messageTextController.dispose();
    closeSignalRConnection();
    super.dispose();
  }

  void _handleMessageChanged() {
    if (mounted) {
      setState(() {
        isMessageEmpty = messageTextController.text.trim().isEmpty;
      });
    }
  }

  Future<void> submitMessageFunction() async {
    if (reciever == null) {
      return;
    }
    var messageText = removeMessageExtraChar(messageTextController.text);

    var message = {
      'MessageId': '',
      'ChatRoomId': widget.chatRoom.chatRoomId,
      'SenderUserId': widget.user.userId,
      'RecieverUserId': reciever!.userId,
      'AttachmentId': '',
      'Content': messageText,
      'CreatedAt': "",
      'ReadedAt': '',
    };

    await connection.invoke('SendMessage', args: [message]);

    messageTextController.text = '';

    Future.delayed(const Duration(milliseconds: 50), () {
      chatListScrollController.animateTo(
        chatListScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (reciever == null) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
        title: Row(
          children: [
            ClipOval(
              child: Image.network(
                reciever!.avatarUrl,
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reciever!.title}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, letterSpacing: 1),
                ),
                Text(
                  '${reciever!.name} ${reciever!.surname}',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 18, letterSpacing: 1),
                )
              ],
            )
          ],
        ),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          children: [
            chatMessageWidget(chatListScrollController, messages,
                widget.user.userId, context),
            chatTypeMessageWidget(
                messageTextController, submitMessageFunction, isMessageEmpty),
          ],
        ),
      ),
    );
  }

  final connection = HubConnectionBuilder()
      .withUrl(
        'http://thisconnect.runasp.net/chathub',
        HttpConnectionOptions(
          logging: (level, message) => print(message),
          transport: HttpTransportType.webSockets,
          skipNegotiation: true,
        ),
      )
      .build();

  Future<void> openSignalRConnection() async {
    await connection.start();
    connection.on('ReceiveMessage', (message) {
      _handleIncomingMessage(message);
    });

    connection.on('ErrorMessage', (error) {
      _handleErrorMessage(error);
    });

    await connection
        .invoke('JoinRoom', args: [widget.chatRoom.chatRoomId, null]);
  }

  Future<void> closeSignalRConnection() async {
    await connection.invoke('LeaveRoom', args: [widget.chatRoom.chatRoomId]);
    await connection.stop();
  }

  Future<void> getOldMessages() async {
    try {
      final List<Message>? results =
          await MessageService.getMessagesByChatRoomId(
        widget.chatRoom.chatRoomId,
      );
      if (results != null) {
        if (mounted) {
          setState(() {
            messages.addAll(results);
            Future.delayed(const Duration(milliseconds: 50), () {
              chatListScrollController.animateTo(
                chatListScrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            });
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _handleIncomingMessage(List<dynamic>? args) async {
    if (args != null) {
      var jsonResponse = json.decode(json.encode(args[0]));
      Message data = Message.fromJson(jsonResponse);
      if (mounted) {
        setState(() {
          messages.add(data);
          Future.delayed(const Duration(milliseconds: 50), () {
            chatListScrollController.animateTo(
              chatListScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          });
        });
      }
    }
  }

  Future<void> getUserInformation() async {
    try {
      final receiverTemp = await UserService.getUserInformation(
        widget.user.userId == widget.chatRoom.participant1Id
            ? widget.chatRoom.participant2Id
            : widget.chatRoom.participant1Id,
      );
      if (mounted) {
        setState(() {
          reciever = receiverTemp;
        });
      }
    } catch (e) {}
  }

  Future<void> _handleErrorMessage(List<dynamic>? args) async {
    if (args != null && args.isNotEmpty) {
      var errorMessage = args[0] as String;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $errorMessage")),
        );
      }
    }
  }
}
