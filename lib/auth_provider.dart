import 'package:e_commerce/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Clase para el estado global de autenticación
class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;

  void login() {
    isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}
