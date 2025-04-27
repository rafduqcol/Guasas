import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String content;
  String? image;
  String chatId;
  String senderId;
  String receiverId;
  DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    this.image,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
  });

  
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      content: map['content'] ?? '',
      image: map['image'],
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'image': image,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
