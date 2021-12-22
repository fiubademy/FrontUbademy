import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiubademy/src/models/message.dart';

class Firestore {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> sendMessage(Message newMessage) async {
    String chatID = [newMessage.senderID, newMessage.receiverID].join('.');
    DocumentReference chat = _firestore.collection('chats').doc(chatID);

    await chat.set({
      'lastMessage': {
        'senderID': newMessage.senderID,
        'receiverID': newMessage.receiverID,
        'content': newMessage.content,
        'timestamp': newMessage.timestamp,
      },
      'users': [newMessage.senderID, newMessage.receiverID]
    });
    await chat.collection('messages').doc().set({
      'senderID': newMessage.senderID,
      'receiverID': newMessage.receiverID,
      'content': newMessage.content,
      'timestamp': newMessage.timestamp.toIso8601String(),
    });
  }

  static Stream<QuerySnapshot> getChats(String userID) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: userID)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMessages(String chatID) {
    return _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();
  }
}
