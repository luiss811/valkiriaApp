// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, use_key_in_widget_constructors, avoid_print

import 'dart:convert';
import 'package:e_commerce/login.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Registro extends StatefulWidget {
  const Registro({Key? key}) : super(key: key);

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  Future<void> _registro() async {
    String usuario = _usuarioController.text;
    String clave = _claveController.text;

    if (usuario.isEmpty || clave.isEmpty) {
      const errorMessage = "Por favor completa todos los campos";
      print('Error al registrar el usuario: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Color(0xFF3555F6),
        ),
      );
      return;
    }

    // En este ejemplo se encripta la contraseña utilizando MD5

    String url = 'http://localhost:3002/GPO_218/api/apiRegistro.php';
    Map<String, String> data = {
      'usuario': usuario,
      'clave': clave,
    };

    var response = await http.post(
      Uri.parse(url),
      body: data,
    );

    if (response.headers['content-type']?.contains('application/json') !=
        true) {
      const errorMessage = "Error en la solicitud HTTP";
      print('Error al registrar el usuario: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Color(0xFF3555F6),
        ),
      );
      return;
    }

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('usuario', usuario);
        _showSuccessDialog("Registro exitoso");
      } else {
        final errorMessage = jsonResponse['message'];
        print('Error al registrar el usuario: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 3),
            backgroundColor: Color(0xFF3555F6),
          ),
        );
      }
    } else {
      const errorMessage = "Error de conexión.";
      print('Error al registrar el usuario: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Color(0xFF3555F6),
        ),
      );
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registro Exitoso"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            child: ColoredBox(
              color: Color.fromARGB(243, 255, 255, 255),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'REGISTRO',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: TextFormField(
                      controller: _usuarioController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        labelText: 'Correo',
                        hintText: 'Ingrese su correo electronico',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu correo electrónico';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: TextFormField(
                      controller: _claveController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        labelText: 'Contraseña',
                        hintText: '*******',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu contraseña';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: SizedBox(
                      width: double.tryParse('200.0'),
                      child: ElevatedButton(
                        onPressed: _registro,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 18, 18, 18),
                          backgroundColor: const Color(0xFF2EAAEC),
                        ),
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: const BoxDecoration(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Ya tienes una cuenta?",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              " Inicia sesión aquí!",
                              style: TextStyle(
                                color: Color(0xFF2EAAEC),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
