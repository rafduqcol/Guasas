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
      'uid': userCredential.user!.uid,
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
