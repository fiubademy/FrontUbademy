import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiubademy/src/models/message.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/firestore.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/widgets/icon_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageListPage extends StatelessWidget {
  const MessageListPage({Key? key}) : super(key: key);

  void _openChat(context, String mail) async {
    final _scaffoldMessenger = ScaffoldMessenger.of(context);
    if (mail.isEmpty) {
      const snackBar =
          SnackBar(content: Text('No users found with that email'));
      _scaffoldMessenger.showSnackBar(snackBar);
    }
    Auth auth = Provider.of<Auth>(context, listen: false);

    Map<String, dynamic> userData = await Server.getUserByEmail(auth, mail);
    if (userData['error'] != null) {
      final snackBar = SnackBar(content: Text(userData['error']));
      _scaffoldMessenger.showSnackBar(snackBar);
    } else {
      User user = User();
      user.updateData(userData['content']);
      // TODO Remove this
      Firestore.sendMessage(
          Message(auth.userID!, user.userID!, "Hello World!"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final _mailController = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text('New Chat'),
                content: TextField(
                  controller: _mailController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: 'Email', hintText: 'example@mail.com'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('CANCEL'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _openChat(context, _mailController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('OPEN'),
                  ),
                ]),
          );
        },
        child: Icon(Icons.message_rounded),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MessageList(),
          ],
        ),
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  Widget _buildChat(DocumentSnapshot chatData) {
    final users = chatData['users'];
    final lastMessage = Message.from(chatData['lastMessage']);

    Auth auth = Provider.of<Auth>(context, listen: false);
    String userID = auth.userID!;
    String otherUserID = users[0] == userID ? users[1] : users[0];

    Future<Map<String, dynamic>?> otherUserData =
        Server.getUser(auth, otherUserID);

    late String timestampAsString;
    DateTime today = DateTime.now();
    bool isToday = lastMessage.timestamp.day == today.day &&
        lastMessage.timestamp.month == today.month &&
        lastMessage.timestamp.year == today.year;
    bool isYesterday = lastMessage.timestamp.day == today.day - 1 &&
        lastMessage.timestamp.month == today.month &&
        lastMessage.timestamp.year == today.year;
    if (isToday) {
      timestampAsString =
          "${lastMessage.timestamp.hour}:${lastMessage.timestamp.minute}";
    } else if (isYesterday) {
      timestampAsString = 'Yesterday';
    } else {
      timestampAsString =
          "${lastMessage.timestamp.day}/${lastMessage.timestamp.month}/${lastMessage.timestamp.year}";
    }

    return FutureBuilder(
      future: otherUserData,
      builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
                child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ));
          default:
            if (snapshot.hasError) {
              return const ListTile(title: Text('Failed to load chat'));
            }

            if (!snapshot.hasData) {
              return const ListTile(title: Text('Failed to load chat'));
            }

            User otherUser = User();
            otherUser.updateData(snapshot.data!);

            return ListTile(
              leading: IconAvatar(avatarID: otherUser.avatarID),
              title: Text(otherUser.username),
              subtitle: Text(lastMessage.content),
              trailing: Text(timestampAsString),
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.getChats(
            Provider.of<Auth>(context, listen: false).userID!),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Text('No chats found',
                      style: Theme.of(context).textTheme.headline6),
                  const SizedBox(height: 16.0),
                  const Text('Try starting a conversation!',
                      style: TextStyle(color: Colors.black54, fontSize: 16))
                ],
              ),
            );
          }

          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return _buildChat(snapshot.data!.docs[index]);
              },
            ),
          );
        });
  }
}
