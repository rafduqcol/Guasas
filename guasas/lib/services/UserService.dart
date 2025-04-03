import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';  // Asegúrate de importar tu clase User

Future<bool> addUserToFirestore(User user) async {
  try {
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await userRef.set(user.toMap());
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
