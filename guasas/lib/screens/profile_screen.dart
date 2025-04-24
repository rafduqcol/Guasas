import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/user.dart' as custom_user;
import '../services/UserService.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;
  custom_user.User? currentUser;
  final UserService _userService = UserService();  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  File? _avatarImage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _loadUserData();
  }

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
      case 2:
        break;
    }
  }

  Future<void> _loadUserData() async {
    custom_user.User? user = await _userService.getCurrentUser();  
    setState(() {
      currentUser = user;
      _firstNameController.text = user?.firstName ?? '';
      _lastNameController.text = user?.lastName ?? '';
      _usernameController.text = user?.username ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;

        if (_avatarImage != null) {
          print("Subiendo archivo de avatar...");

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('avatars')
              .child('${currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
          print("pepes" +  storageRef.fullPath);

          final uploadTask = storageRef.putFile(_avatarImage!);

          print("adios");

          // Esperamos que la subida se complete y verificamos el estado
          final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
          print('Subida de archivo completada con estado: ${snapshot.state}');

          // Obtenemos la URL del archivo subido
          imageUrl = await snapshot.ref.getDownloadURL();
          print('URL del archivo: $imageUrl');
        }

        await _userService.updateUserProfile(
          uid: currentUser!.uid,
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          avatarUrl: imageUrl, // Puede ser null si no se subió una imagen
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Perfil actualizado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el perfil: $e')),
        );
      }
    }
  }

  // Reemplazamos ImagePicker con FilePicker
  Future<void> _pickImage() async {
    // Abrimos el selector de archivos
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'jpeg', 'png']);

    if (result != null) {
      setState(() {
        _avatarImage = File(result.files.single.path!);
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFA4D1BC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            height: 200, 
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Cerrar sesión',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  '¿Estás seguro de que deseas cerrar sesión?',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      ),
                      child: Text(
                        'Cancelar',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () async {
                        await _userService.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cierre de sesión exitoso')));
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      ),
                      child: Text(
                        'Sí',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = const Color(0xFFD6F0E9);
    final Color buttonColor = const Color(0xFFA4D1BC);

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF8BC1A5),
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _avatarImage != null
                              ? FileImage(_avatarImage!)
                              : (currentUser != null && currentUser!.avatarUrl.isNotEmpty
                                  ? NetworkImage(currentUser!.avatarUrl)
                                  : null),
                          child: (_avatarImage == null &&
                                  (currentUser == null || currentUser!.avatarUrl.isEmpty))
                              ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        label: 'Nombre de usuario',
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre de usuario';
                          }
                          if (value.length < 3) {
                            return 'El nombre de usuario debe tener al menos 3 caracteres';
                          }
                          if (value.length > 50) {
                            return 'El nombre de usuario no puede tener más de 50 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        label: 'Nombre',
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu primer nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextFormField(
                        label: 'Apellidos',
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tus apellidos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        text: 'Guardar Cambios',
                        onPressed: _saveProfile,
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        text: 'Cerrar sesión',
                        onPressed: _showLogoutDialog,
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8BC1A5),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
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

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA4D1BC), 
          foregroundColor: const Color(0xFFD6F0E9),  
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: const Color(0xFFD6F0E9), width: 2),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
