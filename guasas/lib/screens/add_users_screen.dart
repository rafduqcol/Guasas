import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import 'main_menu_screen.dart';

class AddUsersScreen extends StatefulWidget {
  const AddUsersScreen({Key? key}) : super(key: key);

  @override
  _AddUsersScreenState createState() => _AddUsersScreenState();
}

class _AddUsersScreenState extends State<AddUsersScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 1; // Indicamos que estamos en la pantalla de agregar usuarios.

  final List<String> _navOptions = ['Listar Chats', 'Agregar Usuarios', 'Perfil'];

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

  // Crear un chat con el usuario seleccionado
  Future<void> createChatWithUser(String userId) async {
    if (currentUser == null || currentUser!.uid.isEmpty) {
      print('No hay usuario actual o el UID está vacío. No se puede crear el chat.');
      return;
    }

    if (currentUser!.uid == userId) {
      print('No puedes crear un chat contigo mismo.');
      return;
    }

    // Crear chat en Firestore
    final chatRef = FirebaseFirestore.instance.collection('chats').doc();
    final chatId = chatRef.id;

    print('Creando chat con ID: $chatId para los usuarios: ${currentUser!.uid} y $userId');

    try {
      // Crear el chat con los usuarios
      await chatRef.set({
        'user1Id': currentUser!.uid, // Usar el uid actual del usuario
        'user2Id': userId,
        'creationDate': FieldValue.serverTimestamp(),
        'messages': [],
      });

      // Imprimir en consola para verificar que el chat se ha creado
      print('Chat creado con ID: $chatId');
      
      // Navegar a la pantalla del chat
      Navigator.pushNamed(context, '/chatDetail', arguments: chatId);
    } catch (e) {
      print('Error creando el chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Usuario'),
      ),
      body: currentUser == null
          ? const Center(child: Text('No estás logueado. Por favor, inicia sesión.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Center(child: Text('Error al cargar usuarios'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.map((doc) {
                  return doc.data() as Map<String, dynamic>;
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userId = user['uid'];
                    final username = user['username'];

                    // Evitar que el usuario actual vea su propio nombre
                    if (userId == currentUser?.uid) {
                      return SizedBox();  // No mostrar su propio nombre
                    }

                    return ListTile(
                      title: Text(username),
                      onTap: () {
                        print('Usuario seleccionado: $username');
                        createChatWithUser(userId);
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
