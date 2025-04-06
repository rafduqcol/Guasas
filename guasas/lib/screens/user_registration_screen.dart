import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/UserService.dart';
import 'login_screen.dart'; 
import 'main_menu_screen.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() =>
      _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _avatarUrl = '';

void _registerUser() async {
  if (_formKey.currentState?.validate() ?? false) {
    _formKey.currentState?.save();

    bool emailExistsFlag = await emailExists(_email);  

    if (emailExistsFlag) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo electrónico ya está registrado')),
      );
      return;
    }

    User newUser = User(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      firstName: _firstName,
      lastName: _lastName,
      username: _username,
      email: _email,
      password: _password,
      onlineStatus: false,
      avatarUrl: _avatarUrl,
    );

    bool success = await addUserToFirestore(newUser);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado exitosamente')),
      );
      
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatListScreen()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error al registrar el usuario')),
      );
    }

    _formKey.currentState?.reset();
  }
}

  @override
  Widget build(BuildContext context) {
    final Color pageColor = const Color(0xFF8BC1A5);
    final Color buttonColor = const Color(0xFFA4D1BC);

    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: const Text(
          'Registrar Usuario',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               _buildTextFormField(
                  label: 'Nombre',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, ingresa tu primer nombre';
                    }
                    if (value!.length < 3) {
                      return 'El primer nombre debe tener al menos 3 caracteres';
                    }
                    if (value.length > 50) {
                      return 'El primer nombre no puede tener más de 50 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) => _firstName = value ?? '',
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Apellido',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, ingresa tu apellido';
                    }
                    if (value!.length < 3) {
                      return 'El apellido debe tener al menos 3 caracteres';
                    }
                    if (value.length > 50) {
                      return 'El apellido no puede tener más de 50 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) => _lastName = value ?? '',
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Nombre de Usuario',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, ingresa tu nombre de usuario';
                    }
                    if (value!.length < 3) {
                      return 'El nombre de usuario debe tener al menos 3 caracteres';
                    }
                    if (value.length > 20) {
                      return 'El nombre de usuario no puede tener más de 20 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) => _username = value ?? '',
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Correo Electrónico',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, ingresa tu correo electrónico';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                      return 'Por favor, ingresa un correo electrónico válido';
                    }
                    if (value.length > 50) {
                      return 'El correo electrónico no puede tener más de 50 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) => _email = value ?? '',
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Contraseña',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, ingresa una contraseña';
                    }
                    if (value!.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                      return 'Debe contener al menos una letra mayúscula y un número';
                    }
                    return null;
                  },
                  onSaved: (value) => _password = value ?? '',
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'URL del Avatar',
                  validator: null,
                  onSaved: (value) => _avatarUrl = value ?? '',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: pageColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: pageColor, width: 2),
                      ),
                    ),
                    child: const Text(
                      'Registrar usuario',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    String? Function(String?)? validator,
    required void Function(String?) onSaved,
    bool obscureText = false,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
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
      onSaved: onSaved,
    );
  }
}
