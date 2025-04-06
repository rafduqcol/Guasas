import 'package:flutter/material.dart';
import '../services/UserService.dart';
import '../models/user.dart' as custom_user;
import 'login_screen.dart';

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _avatarUrl = '';

  final UserService _userService = UserService();

  Widget _buildTextFormField({
    required String label,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
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

  void _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      custom_user.User newUser = custom_user.User(
        firstName: _firstName,
        lastName: _lastName,
        username: _username,
        email: _email,
        password: _password,
        avatarUrl: _avatarUrl,
      );

      String? result = await _userService.registerUser(newUser);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado con éxito')),
        );

        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
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
              children: [
                _buildTextFormField(
                  label: 'Nombre',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, ingresa tu primer nombre';
                    }
                    if (value!.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    if (value.length > 50) {
                      return 'El nombre no puede tener más de 50 caracteres';
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
                  onSaved: (value) => _avatarUrl = value ?? '',
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
                      return 'La contraseña debe contener al menos una letra mayúscula y un número';
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
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: pageColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: pageColor, width: 2),
                      ),
                    ),
                    child: const Text(
                      'Registrar',
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
}
