import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as custom_user;
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        'isGoogleUser': false,
      });
 
      return null;  
    } catch (e) {
      return e.toString();  
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
      // Verifica si el usuario ya existe en Firestore
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
        await _auth.signInWithEmailAndPassword(
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

      User? user = userCredential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'firstName': user.displayName?.split(" ")[0] ?? '',
            'lastName': (user.displayName?.split(" ").length ?? 0) > 1 
                        ? user.displayName?.split(" ")[1] 
                        : '',
            'email': user.email,
            'avatarUrl': user.photoURL ?? '',
            'username': user.displayName?.toLowerCase() ?? '',
            'isGoogleUser': true,
          });
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

  // Función para cerrar sesión
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', false);
  }

  // Obtener el usuario actual
  Future<custom_user.User?> getCurrentUser() async {
    print('Obteniendo usuario actual...');
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return custom_user.User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;  // No hay usuario logueado
  }
}
