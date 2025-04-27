import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class Chat {
  String id;
  List<Message> messages;
  String user1Id;
  String user2Id;
  DateTime creationDate;

  Chat({
    required this.id,
    required this.messages,
    required this.user1Id,
    required this.user2Id,
    required this.creationDate,
  });

  
  factory Chat.fromMap(Map<String, dynamic> map, String documentId) {
    return Chat(
      id: documentId,
      user1Id: map['user1Id'] ?? '',
      user2Id: map['user2Id'] ?? '',
      creationDate: (map['creationDate'] as Timestamp).toDate(),
      messages: map['messages'] != null
          ? List<Message>.from(
          (map['messages'] as List).map((msg) => Message.fromMap(msg)))
          : [],
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'user1Id': user1Id,
      'user2Id': user2Id,
      'creationDate': Timestamp.fromDate(creationDate),
      'messages': messages.map((msg) => msg.toMap()).toList(),
    };
  }
}
