import 'package:flutter/material.dart';
import '../services/UserService.dart';
import '../models/user.dart' as custom_user;
import 'login_screen.dart';
import 'main_menu_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  String _confirmPassword = ''; 
  String _avatarUrl = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final UserService _userService = UserService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isGoogleUser = false;  
  final GoogleSignIn _googleSignIn = GoogleSignIn();



  Widget _buildTextFormField({
    required String label,
    required Function(String?) onSaved,
    String? Function(String?)? validator,
    bool obscureText = false,
    IconButton? suffixIcon,
    TextEditingController? controller,
  }) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
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
        suffixIcon: suffixIcon, 
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
        isGoogleUser: isGoogleUser,  
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
        print("error: $result");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }
  
 void _registerWithGoogle() async {
    try {

      await _googleSignIn.signOut();
      GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      if (googleUser == null) {
        googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Inicio de sesión cancelado')),
          );
          return;
        }
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      custom_user.User newUser = custom_user.User(
        firstName: googleUser.displayName?.split(" ")[0] ?? '',
        lastName: googleUser.displayName?.split(" ").skip(1).join(" ") ?? '',
        username: googleUser.displayName ?? '',
        email: googleUser.email,
        password: "",  
        isGoogleUser: true,
      );

      String? result = await _userService.registerUserWithGoogle(newUser);

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
        print("error: $result");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    } catch (e) {
      print("Error al iniciar sesión con Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hubo un error al registrar con Google')),
      );
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
                  label: 'Apellidos',
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, ingresa tus apellidos';
                    }
                    if (value!.length < 3) {
                      return 'Los apellidos deben tener al menos 3 caracteres';
                    }
                    if (value.length > 50) {
                      return 'Los apellidos no pueden tener más de 50 caracteres';
                    }
                    return null;
                  },
                  onSaved: (value) => _lastName = value ?? '',
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
                  controller: _passwordController, 
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
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),
                _buildTextFormField(
                  label: 'Confirmar Contraseña',
                  controller: _confirmPasswordController, 
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor, confirma tu contraseña';
                    }
                    if (_passwordController.text != value) { 
                      print("Contraseña: ${_passwordController.text} Confirmar Contraseña: $value");
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                  onSaved: (value) => _confirmPassword = value ?? '',
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _registerWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.black),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/images/google_icon.png',
                      height: 24,
                    ),
                    label: const Text('Continuar con Google'),
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
