// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables
import 'dart:convert';
import 'package:e_commerce/catalogo.dart';
import 'package:e_commerce/registro.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  Future<void> _login() async {
    String usuario = _usuarioController.text;
    String clave = _claveController.text;
    if (usuario.isEmpty) {
      const errorMessage = "Por favor ingresa tu nombre de usuario";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Color(0xFF3555F6),
        ),
      );
      return;
    }

    if (!_isCorreoValido(usuario)) {
      const errorMessage =
          "Ingresa un correo valido! Cómo: 'ejemplo@gmail.com'";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 5),
          backgroundColor: Color(0xFF3555F6),
        ),
      );
      return;
    }

    if (clave.length < 6) {
      const errorMessage = "La contraseña debe tener al menos 6 caracteres";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Color(0xFF3555F6),
        ),
      );
      return;
    }
    String url = 'http://localhost:3002/GPO_218/api/apiLogin.php';
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
      const errorMessage = "Error en tu conexión";
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
        int userId = int.parse(jsonResponse['userId']);
        prefs.setInt('userId', userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (contex) => CatalogoScreen(),
          ),
        );
      } else {
        final errorMessage = jsonResponse['message'];
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          backgroundColor: Color(0xFF3555F6),
        ),
      );
    }
  }

  bool _isCorreoValido(String usuario) {
    final usuarioRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return usuarioRegExp.hasMatch(usuario);
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Card(
                      shadowColor: Colors.black54,
                      elevation: 8.0,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'INICIAR SESIÓN',
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
                        prefixIcon: Icon(Icons.person),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          const errorMessage =
                              "Por favor ingresa tu correo electronico";
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Color(0xFF3555F6),
                            ),
                          );
                          return;
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
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          const errorMessage =
                              "Por favor ingresa tu contraseña";
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              duration: const Duration(seconds: 3),
                              backgroundColor: Color(0xFF3555F6),
                            ),
                          );
                          return;
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
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          foregroundColor:
                              const Color.fromARGB(255, 18, 18, 18),
                          backgroundColor: const Color(0xFF2EAAEC),
                        ),
                        child: const Text(
                          "Iniciar Sesión",
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
                            "¿No te has registrado?",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Registro()),
                              );
                            },
                            child: const Text(
                              "Crea una cuenta!",
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
