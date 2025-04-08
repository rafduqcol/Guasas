import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/home.dart';
import 'screens/add_users_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/main_menu_screen.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Función para verificar si el usuario está logueado
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al verificar el estado de login'));
          } else {
            final isLogged = snapshot.data ?? false;
            return isLogged ? ChatListScreen() : LoginScreen();  
          }
        },
      ),
      routes: {
        '/addUsers': (context) => AddUsersScreen(),
        '/chatDetail': (context) => ChatDetailScreen(chatId: ModalRoute.of(context)!.settings.arguments as String),
        '/profile': (context) => ProfileScreen(),  
        '/chatList': (context) => ChatListScreen(),  
      },
    );
  }
}
