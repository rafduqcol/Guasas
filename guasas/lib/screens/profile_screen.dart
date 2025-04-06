import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'add_users_screen.dart';
import 'main_menu_screen.dart';


class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2; // Indicamos que estamos en la pantalla de perfil.

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
        Navigator.pushNamed(context, '/addUsers');
        break;
      case 2:
        break; // Ya estamos en la pantalla de perfil
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    print('Current user: $currentUser');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: currentUser == null
          ? const Center(child: Text('No estás logueado'))
          : Center(
              child: Text(
                'Hola ${currentUser.email}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
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
