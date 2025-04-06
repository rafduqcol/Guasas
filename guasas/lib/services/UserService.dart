import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as custom_user;
import 'package:bcrypt/bcrypt.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser(custom_user.User user) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'username': user.username,
        'email': user.email,
        'password': BCrypt.hashpw(user.password, BCrypt.gensalt()), 
        'avatarUrl': user.avatarUrl,
      });

      return null; 
    } catch (e) {
      return e.toString(); 
    }
  }
  
  Future<custom_user.User?> getUserFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        return custom_user.User.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;  
      }
    } catch (e) {
      print("Error al obtener usuario de Firestore: $e");
      return null;
    }
  }

  Future<String?> loginWithEmailPassword(String email, String password) async {
    try {
      // Verificar si el correo electrónico existe en Firestore
      final userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userSnapshot.docs.isEmpty) {
        return 'El correo electrónico no está registrado.';
      }

      final userDoc = userSnapshot.docs.first;
      final storedHashedPassword = userDoc['password'];

      bool passwordMatch = await BCrypt.checkpw(password, storedHashedPassword);

      if (passwordMatch) {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        return null;
      } else {
        return 'Contraseña incorrecta';
      }
    } catch (e) {
      return 'Error al intentar iniciar sesión: $e';
    }
  }
}
