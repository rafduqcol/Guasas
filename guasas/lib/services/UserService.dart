import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as custom_user;
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_core/firebase_core.dart'; 

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseStorage _storage = FirebaseStorage.instance;

Future<String?> registerUser(custom_user.User user) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: user.password,
    );

    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'uid': userCredential.user!.uid,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'username': user.username,
      'email': user.email,
      'password': BCrypt.hashpw(user.password, BCrypt.gensalt()), 
      'avatarUrl': user.avatarUrl,
      'isGoogleUser': false,
    });

    return null; 

  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      return 'Este correo electrónico ya está registrado.';
    }
    return 'Error de autenticación: ${e.message}';
  } catch (e) {
    return 'Error inesperado: ${e.toString()}';
  }
}

    
 Future<String?> registerUserWithGoogle(custom_user.User user) async {
  try {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return 'El inicio de sesión con Google fue cancelado.';
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);

    User? userFirebase = userCredential.user;

    if (userFirebase != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userFirebase.uid).get();

      if (userDoc.exists) {
        return 'Este correo electrónico ya está registrado con Google.';
      } else {
        await _firestore.collection('users').doc(userFirebase.uid).set({
          'uid': userFirebase.uid,
          'firstName': user.firstName,
          'lastName': user.lastName,
          'username': user.username,
          'email': user.email,
          'avatarUrl': user.avatarUrl ?? '', 
          'isGoogleUser': true,
        });
      }
    }

    return null;  
  } catch (e) {
    return 'Error al registrar con Google: $e';  
  }
}

  Future<String?> loginWithEmailPassword(String email, String password) async {
    try {
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
        UserCredential credential = await _auth.signInWithEmailAndPassword(
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

Future<String?> signInWithGoogle() async {
  try {
    // Inicia el proceso de autenticación con Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return 'El inicio de sesión con Google fue cancelado.';
    }

    // Obtiene el token de acceso y de ID para autenticar con Firebase
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      // Si no existe el usuario en Firestore, retornar un mensaje de error
      if (!userDoc.exists) {
        return 'El correo electrónico no está registrado en nuestro sistema. Por favor, regístrese primero.';
      }

    }

    return null;  
  } catch (e) {
    print("Error al iniciar sesión con Google: $e");
    return e.toString();  
  }
}





  Future<void> saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', true);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', false);
  }

  Future<custom_user.User?> getCurrentUser() async {
    print('Obteniendo usuario actual...');
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return custom_user.User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;  
  }

Future<void> updateUserProfile(String uid, String firstName, String lastName, String username) async {
  try {
    String? avatarUrl;
   

    await _firestore.collection('users').doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
    });
  } catch (e) {
    print("Error al actualizar el perfil: $e");
  }
}
}

