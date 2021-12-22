import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiubademy/src/models/message.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/firestore.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/widgets/icon_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  final User user;
  const ChatPage({Key? key, required this.user}) : super(key: key);

  Widget _buildMessage(context, DocumentSnapshot<Map<String, dynamic>> messageData) {
    String myID = Provider.of<Auth>(context, listen: false).userID!;
    Message message = Message.from(Map.castFrom(messageData.data()!));
    if (message.senderID == myID) {
      return Row(
        children: <Widget>[
          // Text
          Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Bubble(
                  color: Colors.blueGrey,
                  elevation: 0,
                  padding: const BubbleEdges.all(10.0),
                  nip: BubbleNip.rightTop,
                  child: Text(document['content'],
                      style: TextStyle(color: Colors.white))),
              width: 200)
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                child: Bubble(
                    color: Colors.white10,
                    elevation: 0,
                    padding: const BubbleEdges.all(10.0),
                    nip: BubbleNip.leftTop,
                    child: Text(document['content'],
                        style: TextStyle(color: Colors.white))),
                width: 200.0,
                margin: const EdgeInsets.only(left: 10.0),
              )
            ])
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
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
        child: StreamBuilder(
          stream: Firestore.getMessages(chatID),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    Text('No messages found',
                        style: Theme.of(context).textTheme.headline6),
                    const SizedBox(height: 16.0),
                    const Text('Try sending a message!',
                        style: TextStyle(color: Colors.black54, fontSize: 16))
                  ],
                ),
              );
            }
            final a = snapshot.data!.docs[0].data();

            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return _buildMessage(context, 
                  snapshot.data!.docs[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
