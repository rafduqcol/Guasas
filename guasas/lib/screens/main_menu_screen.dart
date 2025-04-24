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

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre de usuario...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                }).where((chat) =>
                  chat.user1Id == currentUserId || chat.user2Id == currentUserId
                ).toList();

                if (chats.isEmpty) {
                  return const Center(child: Text('Aún no tienes chats'));
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final lastMsg = getLastMessage(chat.messages);

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
                        final avatarUrl = userData['avatarUrl'] ?? '';

                        // Aplica filtro de búsqueda
                        if (!_searchText.isEmpty &&
                            !userName.toLowerCase().contains(_searchText)) {
                          return const SizedBox.shrink(); // Oculta si no hace match
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFFFFF),
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
                              leading: CircleAvatar(
                                    radius: 24,
                                    backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    backgroundColor: Color(0xFF8BC1A5),
                                    child: (avatarUrl == null || avatarUrl.isEmpty)
                                        ? Text(
                                            userName.isNotEmpty ? userName[0].toUpperCase() : '',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          )
                                        : null,
                                  ),
                            title: Text(
                              '$userName',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(lastMsg),
                            onTap: () {
                              Navigator.pushNamed(context, '/chatDetail', arguments: chat.id);
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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
