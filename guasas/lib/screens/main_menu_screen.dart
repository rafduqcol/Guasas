import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
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
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFD6F0E9),
      appBar: AppBar(
        title: const Text('Mis Chats'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8BC1A5), 
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
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

              // Determinar el otro usuario del chat
              final otherUserId = (chat.user1Id == currentUserId)
                  ? chat.user2Id
                  : chat.user1Id;

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Cargando usuario...'),
                      subtitle: Text('...'),
                    );
                  }

                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      !userSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Usuario no encontrado'),
                      subtitle: Text(lastMsg),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['username'] ?? 'Usuario desconocido';

return Column(
  children: [
    Container(
      decoration: BoxDecoration(
      color: const Color(0xFFEFFFFF), // ← tu color personalizado
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: ListTile(
        title: Text(
          'Chat con $userName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(lastMsg),
        onTap: () {
          Navigator.pushNamed(context, '/chatDetail', arguments: chat.id);
        },
      ),
    ),
  ],
);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8BC1A5),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
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
