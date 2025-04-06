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

  Future<void> createChatWithUser(String userId, String username) async {
    if (currentUser == null) {
      print('No hay usuario actual. No se puede crear el chat.');
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
      body: StreamBuilder<QuerySnapshot>(
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

              return ListTile(
                title: Text(username),
                onTap: () {
                  print('Usuario seleccionado: $username');
                  createChatWithUser(userId, username);
                },
              );
            },
          );
        },
      ),
    );
  }
}
