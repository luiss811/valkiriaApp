// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:e_commerce/carrito.dart';
import 'package:e_commerce/catalogo.dart';
import 'package:e_commerce/historial.dart';
import 'package:e_commerce/listaDeseos.dart';
import 'package:e_commerce/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CatalogoScreen()),
                );
              },
              child: RichText(
                text: const TextSpan(
                  text: 'Valkiria',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _onTabTapped(0);
                  },
                  icon: Icon(
                    Icons.home_filled,
                    size: 25,
                    color: _currentIndex == 0
                        ? const Color(0xB2021EF1)
                        : Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _onTabTapped(1);
                  },
                  icon: Icon(Icons.favorite,
                      size: 25,
                      color: _currentIndex == 1
                          ? const Color(0xB2021EF1)
                          : Colors.blue),
                ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () {
                        _onTabTapped(2);
                      },
                      icon: Icon(
                        Icons.shopping_cart_rounded,
                        size: 25,
                        color: _currentIndex == 2
                            ? const Color(0xB2021EF1)
                            : Colors.blue,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    _onTabTapped(3);
                  },
                  icon: Icon(
                    Icons.history_rounded,
                    size: 25,
                    color: _currentIndex == 3
                        ? const Color(0xB2021EF1)
                        : Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _confirmLogout();
                  },
                  icon: Icon(
                    Icons.person_remove_alt_1_rounded,
                    size: 25,
                    color: _currentIndex == 4
                        ? const Color(0xB2021EF1)
                        : Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CatalogoScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListaDeseos()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Carrito()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Historial()),
        );
        break;
      case 4:
        break;
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¿Cerrar sesión?"),
          content: const Text("¿Está seguro de que desea cerrar sesión?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _logout();
                Navigator.of(context).pop();
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
