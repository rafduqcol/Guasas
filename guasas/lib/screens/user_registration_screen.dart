import 'package:flutter/material.dart';
import '../models/user.dart'; // Asegúrate de tener la clase User importada
import '../services/UserService.dart'; // Importa el servicio de Firestore

class UserRegistrationScreen extends StatefulWidget {
  @override
  _UserRegistrationScreenState createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();  // Clave para validar el formulario

  // Variables de los campos de entrada
  String _firstName = '';
  String _lastName = '';
  String _username = '';
  String _email = '';
  String _password = '';
  String _avatarUrl = '';

  // Función para registrar al usuario
  void _registerUser() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      // Crear el objeto User con los datos del formulario
      User newUser = User(
        uid: DateTime.now().millisecondsSinceEpoch.toString(), // Usamos un valor temporal para el uid
        firstName: _firstName,
        lastName: _lastName,
        username: _username,
        email: _email,
        password: _password,
        onlineStatus: false,  // Puedes establecerlo como false, hasta que el usuario se conecte
        avatarUrl: _avatarUrl,
      );

      // Guarda el usuario en Firestore
      addUserToFirestore(newUser);

      // Mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario registrado exitosamente')),
      );

      // Limpiar el formulario
      _formKey.currentState?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Primer Nombre'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa tu primer nombre';
                  }
                  return null;
                },
                onSaved: (value) => _firstName = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Apellido'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa tu apellido';
                  }
                  return null;
                },
                onSaved: (value) => _lastName = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre de Usuario'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa tu nombre de usuario';
                  }
                  return null;
                },
                onSaved: (value) => _username = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Correo Electrónico'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa tu correo electrónico';
                  }
                  return null;
                },
                onSaved: (value) => _email = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Por favor, ingresa una contraseña';
                  }
                  return null;
                },
                onSaved: (value) => _password = value ?? '',
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'URL del Avatar'),
                onSaved: (value) => _avatarUrl = value ?? '',
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerUser,  // Llamada a la función de registro
                child: Text('Registrar Usuario'),
              ),
            ],
          ),
        ),
     ),
);
}
}