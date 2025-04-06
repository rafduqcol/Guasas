import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: currentUser == null
          ? const Center(child: Text('No estás logueado'))
          : Center(
              child: Text(
                'Hola ${currentUser.displayName ?? 'Usuario Guasón'}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
