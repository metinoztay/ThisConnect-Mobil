import 'package:thisconnect/models/chatroom_model.dart';
import 'package:thisconnect/models/message_model.dart';
import 'package:thisconnect/models/user_model.dart';
import 'package:thisconnect/screens/chat_screen.dart';
import 'package:thisconnect/services/api_handler.dart';
import 'package:flutter/material.dart';
import 'package:thisconnect/services/pref_handler.dart';

class MessagesScreen extends StatefulWidget {
  final User user;
  const MessagesScreen({super.key, required this.user});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ChatRoom> chatRooms = [];
  @override
  void initState() {
    super.initState();
    //getPrefUserInformation();
    ApiHandler.updateLastSeenAt(widget.user.userId);
    getChatRoomsByParticipant(widget.user.userId);
    //readUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            Future<User> userFuture = getUserInformation(
                chatRooms[index].participant1Id == widget.user.userId
                    ? chatRooms[index].participant2Id
                    : chatRooms[index].participant1Id);
            return FutureBuilder<User>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final User tempUser = snapshot.data!;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => ChatScreen(
                            widget.user,
                            chatRooms[index],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              tempUser.title +
                                  " " +
                                  tempUser.name +
                                  " " +
                                  tempUser.surname,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(tempUser.avatarUrl!),
                      ),
                      subtitle: Expanded(
                        child: FutureBuilder<Message>(
                          future: getLastMessage(
                            chatRooms[index].lastMessageId != null
                                ? chatRooms[index].lastMessageId!
                                : '',
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data!.content.length > 20
                                    ? snapshot.data!.content.substring(0, 20) +
                                        '...'
                                    : snapshot.data!.content,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.left,
                              );
                            }
                            return const Text(' ');
                          },
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> getChatRoomsByParticipant(String userId) async {
    final results = await ApiHandler.getChatRoomsByParticipant(userId);

    setState(() {
      chatRooms.clear();
      chatRooms = results;
    });
  }

  Future<User> getUserInformation(String userId) async {
    final result = await ApiHandler.getUserInformation(userId);
    return result;
  }

  Future<Message> getLastMessage(String messageId) async {
    final result = await ApiHandler.getMessageByMessageId(messageId);
    return result;
  }
}
