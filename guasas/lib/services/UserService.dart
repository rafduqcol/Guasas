import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as custom_user;
import 'package:bcrypt/bcrypt.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Función para registrar un usuario
  Future<String?> registerUser(custom_user.User user) async {
    try {
      // Crear un usuario con correo y contraseña
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // Insertar los datos en Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'username': user.username,
        'email': user.email,
        'password': BCrypt.hashpw(user.password, BCrypt.gensalt()), 
        'avatarUrl': user.avatarUrl,
      });
 
      return null;  // Registro exitoso
    } catch (e) {
      return e.toString();  // En caso de error
    }
  }

  // Función para login con email y contraseña
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
        // Iniciar sesión con las credenciales
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return null;  // Login exitoso
      } else {
        return 'Contraseña incorrecta';
      }
    } catch (e) {
      return 'Error al intentar iniciar sesión: $e';
    }
  }

  // Función para iniciar sesión con Google
  Future<String?> signInWithGoogle() async {
    try {
      // Autenticación con Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return 'El inicio de sesión con Google fue cancelado.';
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear las credenciales de Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Iniciar sesión con las credenciales de Google
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Obtener los datos del usuario
      User? user = userCredential.user;

      if (user != null) {
        // Verificar si el usuario ya existe en Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Si no existe, crearlo en Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'firstName': user.displayName?.split(" ")[0] ?? '',
            'lastName': (user.displayName?.split(" ").length ?? 0) > 1 
                        ? user.displayName?.split(" ")[1] 
                        : '',
            'email': user.email,
            'avatarUrl': user.photoURL ?? '',
            'username': user.displayName?.toLowerCase() ?? '',
          });
        }
      }

      return null;  // Inicio de sesión con Google exitoso
    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
      return e.toString();  // Devolver el error si ocurre alguno
    }
  }
}
