import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import '../models/message.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedIndex = 0;

  final List<String> _navOptions = ['Listar Chats', 'Agregar Usuarios', 'Perfil'];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
      // Ya estás en esta pantalla
        break;
      case 1:
        Navigator.pushNamed(context, '/addUsers');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  String getLastMessage(List<Message> messages) {
    if (messages.isEmpty) return 'Sin mensajes';
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.first.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('creationDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error al cargar chats'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Chat.fromMap(data, doc.id);
          }).toList();

          if (chats.isEmpty) {
            return const Center(child: Text('Aún no tienes chats'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final lastMsg = getLastMessage(chat.messages);
              final otherUserId = chat.user1Id; // esto deberías cambiarlo luego por lógica

              return ListTile(
                title: Text('Chat con $otherUserId'),
                subtitle: Text(lastMsg),
                onTap: () {
                  Navigator.pushNamed(context, '/chatDetail', arguments: chat.id);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Agregar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
