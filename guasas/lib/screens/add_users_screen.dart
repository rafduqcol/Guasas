import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddUsersScreen extends StatefulWidget {
  const AddUsersScreen({Key? key}) : super(key: key);

  @override
  _AddUsersScreenState createState() => _AddUsersScreenState();
}

class _AddUsersScreenState extends State<AddUsersScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 1;

  final List<String> _navOptions = ['Listar Chats', 'Agregar Usuarios', 'Perfil'];
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/chatList');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Future<String?> checkIfChatExists(String userId) async {
    final chatsRef = FirebaseFirestore.instance.collection('chats');
    final existingChats = await chatsRef
        .where('user1Id', whereIn: [currentUser!.uid, userId])
        .get();

    for (var doc in existingChats.docs) {
      final data = doc.data();
      final user1 = data['user1Id'];
      final user2 = data['user2Id'];

      if ((user1 == currentUser!.uid && user2 == userId) ||
          (user1 == userId && user2 == currentUser!.uid)) {
        return doc.id; 
      }
    }
    return null;
  }

 
  Future<void> createChatWithUser(String userId) async {
    if (currentUser == null || currentUser!.uid.isEmpty) {
      print('No hay usuario actual. No se puede crear el chat.');
      return;
    }

    if (currentUser!.uid == userId) {
      print('No puedes crear un chat contigo mismo.');
      return;
    }

    final existingChatId = await checkIfChatExists(userId);

    if (existingChatId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ya tienes un chat con este usuario.'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final chatRef = FirebaseFirestore.instance.collection('chats').doc();
    final chatId = chatRef.id;

    try {
      await chatRef.set({
        'user1Id': currentUser!.uid,
        'user2Id': userId,
        'creationDate': FieldValue.serverTimestamp(),
        'messages': [],
      });

      print('Chat creado con ID: $chatId');
      Navigator.pushNamed(context, '/chatDetail', arguments: chatId);
    } catch (e) {
      print('Error creando el chat: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6F0E9),
      appBar: AppBar(
        title: const Text('Agregar Usuario'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8BC1A5),
      ),
      body: currentUser == null
          ? const Center(child: Text('No estás logueado.'))
          : Column(
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
                      hintText: 'Buscar usuario...',
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
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return const Center(child: Text('Error al cargar usuarios'));
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final users = snapshot.data!.docs.map((doc) {
                        return doc.data() as Map<String, dynamic>;
                      }).where((user) {
                        final username = (user['username'] ?? '').toLowerCase();
                        return user['uid'] != currentUser?.uid &&
                            username.contains(_searchText);
                      }).toList();

                      return ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final userId = user['uid'];
                          final username = user['username'];

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
                              title: Text(
                                username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                createChatWithUser(userId);
                              },
                            ),
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
