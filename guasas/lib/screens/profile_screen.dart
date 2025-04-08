import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; 
import 'package:firebase_storage/firebase_storage.dart'; 
import '../models/user.dart' as custom_user;
import '../services/UserService.dart'; 
import 'login_screen.dart'; 
import 'home.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 2;
  late custom_user.User currentUser;
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  File? _avatarImage; 

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _loadUserData();
  }

  // Cargar los datos del usuario
  Future<void> _loadUserData() async {
    custom_user.User? user = await getCurrentUser();
    if (user != null) {
      setState(() {
        currentUser = user;
        _firstNameController.text = user.firstName ?? '';
        _lastNameController.text = user.lastName ?? '';
        _usernameController.text = user.username ?? '';
      });
    }
  }

  // Obtener el usuario actual
  Future<custom_user.User?> getCurrentUser() async {
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
      if (userDoc.exists) {
        return custom_user.User.fromMap(userDoc.data() as Map<String, dynamic>);
      }
    }
    return null;
  }

  // Función para seleccionar la imagen
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _avatarImage = File(image.path); 
      });
    }
  }

  // Función para guardar los datos
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'username': _usernameController.text,
        if (_avatarImage != null) 'avatarUrl': await _uploadAvatarImage(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perfil actualizado')));
    }
  }

void _logout() async {
  await _userService.signOut();

  // Redirigir a la pantalla de inicio de sesión
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Cierre de sesión exitoso')),
  );

  // Espera 2 segundos antes de redirigir
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  });
}
  // Función para subir la imagen del avatar
  Future<String> _uploadAvatarImage() async {
    // Usa Firebase Storage para subir la imagen (esto es solo un ejemplo)
    String path = 'avatars/${currentUser.uid}.jpg';
    final ref = FirebaseStorage.instance.ref().child(path);
    await ref.putFile(_avatarImage!);
    String avatarUrl = await ref.getDownloadURL();
    return avatarUrl;
  }

  // Función para cambiar la contraseña (abre el modal)
  Future<void> _showChangePasswordModal() async {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextFormField(
                controller: _currentPasswordController,
                label: 'Contraseña actual',
                obscureText: _obscureCurrentPassword,
              ),
              const SizedBox(height: 10),
              _buildTextFormField(
                controller: _newPasswordController,
                label: 'Nueva contraseña',
                obscureText: _obscureNewPassword,
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 20),
                TextButton(
                  onPressed: () {
                    String currentPassword = _currentPasswordController.text;
                    String newPassword = _newPasswordController.text;
                    if (currentPassword.isNotEmpty && newPassword.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contraseña cambiada')));
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Por favor ingresa ambas contraseñas')));
                    }
                  },
                  child: const Text('Cambiar'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color pageColor = const Color(0xFF8BC1A5);
    final Color buttonColor = const Color(0xFFA4D1BC);

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
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
                          radius: 50,
                          backgroundImage: _avatarImage != null
                              ? FileImage(_avatarImage!) 
                              : NetworkImage(currentUser.avatarUrl) as ImageProvider,
                          child: _avatarImage == null
                              ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
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
                          if (value.length < 3) {
                            return 'El nombre debe tener al menos 3 caracteres';
                          }
                          if (value.length > 50) {
                            return 'El nombre no puede tener más de 50 caracteres';
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
                          if (value.length < 3) {
                            return 'Los apellidos deben tener al menos 3 caracteres';
                          }
                          if (value.length > 50) {
                            return 'Los apellidos no pueden tener más de 50 caracteres';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    if (!currentUser.isGoogleUser)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _showChangePasswordModal,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor, 
                              foregroundColor: pageColor, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: pageColor, width: 2),
                              ),
                            ),
                            child: const Text(
                              'Cambiar Contraseña',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor, 
                          foregroundColor: pageColor, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: pageColor, width: 2),
                          ),
                        ),
                        child: const Text(
                          'Guardar Cambios',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                     SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor, 
                          foregroundColor: pageColor, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: pageColor, width: 2),
                          ),
                        ),
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),

                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/chatList');
              break;
            case 1:
              Navigator.pushNamed(context, '/addUsers');
              break;
            case 2:
              break; // No navega en el perfil
          }
        },
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

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller, // Añadí controller como parámetro requerido
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white), // Estilo corregido aquí
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
