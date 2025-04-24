import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_selector/file_selector.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? otherUserName;
  String otherAvatarUrl = '';

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentUser == null) return;

    final newMessage = Message(
      id: FirebaseFirestore.instance.collection('messages').doc().id,
      content: _messageController.text.trim(),
      image: null,
      chatId: widget.chatId,
      senderId: currentUser!.uid,
      receiverId: '',
      timestamp: DateTime.now(),
    );

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'messages': FieldValue.arrayUnion([newMessage.toMap()])
    });

    _messageController.clear();
  }

  Future<void> sendImage() async {
    if (currentUser == null) return;

    final XFile? file = await openFile(acceptedTypeGroups: [
      XTypeGroup(label: 'images', extensions: ['jpg', 'jpeg', 'png'])
    ]);

    if (file != null) {
      final uid = currentUser!.uid;
      final ref = _storage.ref().child('chatImages/${DateTime.now().millisecondsSinceEpoch}_$uid.jpg');

      final uploadTask = await ref.putData(await file.readAsBytes());
      final downloadUrl = await ref.getDownloadURL();

      final newMessage = Message(
        id: FirebaseFirestore.instance.collection('messages').doc().id,
        content: '',
        image: downloadUrl,
        chatId: widget.chatId,
        senderId: uid,
        receiverId: '',
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
        'messages': FieldValue.arrayUnion([newMessage.toMap()])
      });
    }
  }

  Future<void> fetchOtherUserName(Chat chat) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final otherUserId = chat.user1Id == currentUserId ? chat.user2Id : chat.user1Id;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();

    if (userDoc.exists) {
      final data = userDoc.data() as Map<String, dynamic>;
      setState(() {
        otherUserName = data['username'] ?? 'Usuario';
        otherAvatarUrl = data['avatarUrl'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F0E9),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: CircleAvatar(
            radius: 24,
            backgroundImage: (otherAvatarUrl.isNotEmpty)
                ? NetworkImage(otherAvatarUrl)
                : null,
            backgroundColor: const Color(0xFF8BC1A5),
            child: (otherAvatarUrl.isEmpty && otherUserName != null)
                ? Text(
                    otherUserName!.isNotEmpty ? otherUserName![0].toUpperCase() : '',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
        ),
        title: Text('Chat con ${otherUserName ?? '...'}'),
        backgroundColor: const Color(0xFF8BC1A5),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error'));
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Chat no encontrado'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final chat = Chat.fromMap(data, snapshot.data!.id);

                if (otherUserName == null) {
                  fetchOtherUserName(chat);
                }

                final messages = chat.messages..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: msg.image != null && msg.image!.isNotEmpty
                            ? Image.network(msg.image!)
                            : Text(msg.content),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
