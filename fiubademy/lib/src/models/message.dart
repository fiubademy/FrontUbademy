import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String _senderID;
  final String _receiverID;
  final DateTime _timestamp;
  final String _content;

  Message(String senderID, String receiverID, String content)
      : _senderID = senderID,
        _receiverID = receiverID,
        _content = content,
        _timestamp = DateTime.now();

  Message.from(Map<String, dynamic> messageData)
      : _senderID = messageData['senderID'],
        _receiverID = messageData['receiverID'],
        _timestamp = messageData['timestamp'].toDate(),
        _content = messageData['content'];

  String get senderID => _senderID;
  String get receiverID => _receiverID;
  String get content => _content;
  DateTime get timestamp => _timestamp;
}
