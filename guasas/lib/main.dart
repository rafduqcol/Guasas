import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/add_users_screen.dart';
import 'screens/chat_detail_screen.dart';
import 'screens/profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
      routes: {
        '/addUsers': (context) => AddUsersScreen(), // Ruta para la pantalla de agregar usuarios
        '/chatDetail': (context) => ChatDetailScreen(chatId: ModalRoute.of(context)!.settings.arguments as String),
        '/profile': (context) => ProfileScreen(), // Ruta para la pantalla de perfil
      },
    );
  }
}
