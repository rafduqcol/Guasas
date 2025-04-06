import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcrypt/bcrypt.dart'; 
import '../models/user.dart';  



Future<bool> emailExists(String email) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  } on FirebaseException catch (e) {
    print("Error de Firebase al comprobar si el correo electrónico existe: ${e.message}");
    return false;
  } catch (e) {
    print("Error inesperado al comprobar si el correo electrónico existe: $e");
    return false;
  }
}


Future<bool> addUserToFirestore(User user) async {
  try {
    String hashedPassword = BCrypt.hashpw(user.password, BCrypt.gensalt());

    final userWithHashedPassword = user.copyWith(password: hashedPassword);

    final userRef = FirebaseFirestore.instance.collection('users').doc(userWithHashedPassword.uid);
    await userRef.set(userWithHashedPassword.toMap());
    print("Usuario guardado exitosamente");
    return true;
  } on FirebaseException catch (e) {
    print("Error de Firebase al guardar el usuario: ${e.message}");
    return false;
  } catch (e) {
    print("Error inesperado al guardar el usuario: $e");
    return false;
  }
}

Future<User?> getUserFromFirestore(String uid) async {
  try {
    final docSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      return User.fromMap(docSnapshot.data()!);
    } else {
      print("Usuario no encontrado");
      return null;
    }
  } on FirebaseException catch (e) {
    print("Error de Firebase al obtener el usuario: ${e.message}");
    return null;
  } catch (e) {
    print("Error inesperado al obtener el usuario: $e");
    return null;
  }
}
