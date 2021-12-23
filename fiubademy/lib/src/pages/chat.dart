import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ubademy/src/models/message.dart';
import 'package:ubademy/src/services/auth.dart';
import 'package:ubademy/src/services/firestore.dart';
import 'package:ubademy/src/services/server.dart';
import 'package:ubademy/src/services/user.dart';
import 'package:ubademy/src/widgets/icon_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bubble/bubble.dart';

class ChatPage extends StatelessWidget {
  final User user;
  final _messageController = TextEditingController();
  final ScrollController _listScrollController = ScrollController();

  ChatPage({Key? key, required this.user}) : super(key: key);

  void _sendMessage(context) {
    if (_messageController.text.trim() != '') {
      Auth auth = Provider.of<Auth>(context, listen: false);
      Message newMessage =
          Message(auth.userID!, user.userID!, _messageController.text.trim());
      _messageController.clear();
      Firestore.sendMessage(newMessage);
      Server.notifyUser(auth, user.userID!,
          'New message from ${Provider.of<User>(context, listen: false).username}');
      if (_listScrollController.hasClients) {
        _listScrollController.animateTo(0.0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }
  }

  Widget _buildMessage(context,
      DocumentSnapshot<Map<String, dynamic>> messageData, bool changeInSender) {
    String myID = Provider.of<Auth>(context, listen: false).userID!;
    Message message = Message.from(messageData.data()!);

    DateTime today = DateTime.now();
    String timestampAsString =
        '${message.timestamp.day}/${message.timestamp.month}/${message.timestamp.year}';

    bool isToday = message.timestamp.day == today.day &&
        message.timestamp.month == today.month &&
        message.timestamp.year == today.year;
    if (isToday) {
      timestampAsString =
          '${message.timestamp.hour}:${message.timestamp.minute}';
    } else {
      timestampAsString +=
          ' ${message.timestamp.hour}:${message.timestamp.minute}';
    }

    if (message.senderID == myID) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Bubble(
                  color: Theme.of(context).colorScheme.secondaryVariant,
                  elevation: 3,
                  padding: const BubbleEdges.all(0),
                  showNip: changeInSender,
                  nip: BubbleNip.rightTop,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 20,
                        ),
                        child: Text(
                          message.content,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 10,
                        child: Text(
                          timestampAsString,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.66,
                  minWidth: isToday ? 96 : 136,
                ),
                margin: EdgeInsets.only(
                  right: 8.0,
                  top: (changeInSender ? 16.0 : 4.0),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Container(
                child: Bubble(
                  color: Colors.grey[300],
                  elevation: 3,
                  padding: const BubbleEdges.all(0),
                  showNip: changeInSender,
                  nip: BubbleNip.leftTop,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 20,
                        ),
                        child: Text(
                          message.content,
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 16),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 10,
                        child: Text(
                          timestampAsString,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.66,
                  minWidth: isToday ? 96 : 136,
                ),
                margin: EdgeInsets.only(
                  left: 8.0,
                  top: (changeInSender ? 16.0 : 4.0),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List userIDs = [
      Provider.of<Auth>(context, listen: false).userID!,
      user.userID
    ];
    userIDs.sort();
    String chatID = userIDs.join('.');
    return Scaffold(
      appBar: AppBar(title: Text(user.username), actions: [
        Container(
          alignment: Alignment.centerLeft,
          height: 56,
          width: 64,
          child: IconAvatar(avatarID: user.avatarID, height: 48, width: 48),
        ),
      ]),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: Firestore.getMessages(chatID),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No messages found',
                              style: Theme.of(context).textTheme.headline6),
                          const SizedBox(height: 16.0),
                          const Text('Try sending a message!',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 16))
                        ],
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final message = snapshot.data!.docs[index];
                      bool changeInSender = true;
                      if (index + 1 < snapshot.data!.docs.length) {
                        changeInSender =
                            snapshot.data!.docs[index + 1].data()['senderID'] !=
                                message.data()['senderID'];
                        //print('${index - 1}  != $index : $changeInSender');
                        //print(
                        //'${snapshot.data!.docs[index - 1].data()['senderID']} != ${message.data()['senderID']}');
                        //print(
                        //'${snapshot.data!.docs[index - 1].data()['content']} != ${message.data()['content']}');
                      }

                      return _buildMessage(context, message, changeInSender);
                    },
                    reverse: true,
                    controller: _listScrollController,
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        minLines: 1,
                        maxLines: 5,
                        controller: _messageController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Message',
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _sendMessage(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
