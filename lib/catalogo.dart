// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:e_commerce/barra_navegacion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({Key? key}) : super(key: key);

  @override
  _CatalogoScreenState createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  late List<Sucursal> sucursales = [];
  late List<Producto> productos = [];
  late Sucursal? selectedSucursal;

  @override
  void initState() {
    super.initState();
    _getDatos();
  }

  Future<void> _getDatos() async {
    await _getSucursales();
    if (sucursales.isNotEmpty) {
      setState(() {
        selectedSucursal = sucursales[0];
      });
      _getProductos(selectedSucursal!.id);
    }
  }

  Future<void> _getSucursales() async {
    final response = await http
        .get(Uri.parse('http://localhost:3002/GPO_218/api/apiSucursal.php'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        sucursales = data.map((item) => Sucursal.fromJson(item)).toList();
      });
    } else {
      throw Exception('Error al traer las sucursales');
    }
  }

  Future<void> _getProductos(int sucursalId) async {
    final response = await http.get(Uri.parse(
        'http://localhost:3002/GPO_218/api/apiCatalogoSuc.php?sucursal=$sucursalId'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        productos = data.map((item) {
          Producto producto = Producto.fromJson(item);
          producto.inventoryId = item['id_inv'];
          return producto;
        }).toList();
      });
    } else {
      throw Exception('Error al traer los productos');
    }
  }

  Future<void> _addToCart(int userId, int inventoryId) async {
    final response = await http.post(
      Uri.parse('http://localhost:3002/GPO_218/api/apiAddCart.php'),
      body: {
        'id_usu': userId.toString(),
        'id_inv': inventoryId.toString(),
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: const Color.fromARGB(222, 47, 207, 50),
          ),
        );
      } else {
        _showErrorDialog(data['message']);
      }
      print(response.body);
    } else {
      throw Exception('Error al agregar producto al carrito');
    }
  }

  Future<void> _addToWishList(int userId, int inventoryId) async {
    final response = await http.post(
      Uri.parse('http://localhost:3002/GPO_218/api/apiAddWishList.php'),
      body: {
        'id_usu': userId.toString(),
        'id_inv': inventoryId.toString(),
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto añadido a su lista de deseos."),
            backgroundColor: Color.fromARGB(222, 47, 207, 50),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo añadir a su lista de deseos!"),
            backgroundColor: Colors.red,
          ),
        );
      }
      // print(response.body);
    } else {
      throw Exception('Error al añadirlo a su lista de deseos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 10,
        title: Row(
          children: [
            const BottomNav(),
            PopupMenuButton<Sucursal>(
              onSelected: (Sucursal result) {
                setState(() {
                  selectedSucursal = result;
                });
                _getProductos(selectedSucursal!.id);
              },
              itemBuilder: (BuildContext context) => sucursales.map((sucursal) {
                return PopupMenuItem<Sucursal>(
                  value: sucursal,
                  child: Text(sucursal.nombre),
                );
              }).toList(),
              child: const Icon(
                Icons.local_mall_rounded,
                size: 25,
                color: Colors.blue,
              ),
            ),
            // Column(
            //   children: [
            //     SizedBox(
            //       height: 200,
            //       child: PageView(
            //         children: [
            //           Image.asset('./catan.jpg', fit: BoxFit.cover),
            //           Image.asset('./galaxyTrucker.jpg', fit: BoxFit.cover),
            //           Image.asset('./arkamhorrors.jpg', fit: BoxFit.cover),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            const Spacer(),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (productos.isEmpty)
                const Text(
                  "Selecciona una sucursal para ver sus productos!",
                  style: TextStyle(fontSize: 16),
                )
              else
                Column(
                  children: productos.map((producto) {
                    return ProductCard(
                      imagePath: producto.rutaImg,
                      title: producto.nombre,
                      price: producto.precio.toString(),
                      description: producto.descripcion,
                      branchName: producto.nombreSucursal,
                      availableQuantity: producto.cantidadDisponible,
                      onTapAddToCart: () {
                        SharedPreferences.getInstance().then((prefs) {
                          int userId = prefs.getInt('userId') ?? 0;
                          if (userId != 0) {
                            _addToCart(userId, producto.inventoryId);
                          } else {
                            _showErrorDialog(
                                "Necesitas tener una cuenta para añadirlo");
                          }
                        });
                      },
                      onTapAddToWishList: () {
                        SharedPreferences.getInstance().then((prefs) {
                          int userId = prefs.getInt('userId') ?? 0;
                          if (userId != 0) {
                            _addToWishList(userId, producto.inventoryId);
                          } else {
                            _showErrorDialog(
                                "Necesitas tener una cuenta para añadirlo");
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 200.0),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(217, 255, 255, 255),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

class Sucursal {
  final int id;
  final String nombre;

  Sucursal({
    required this.id,
    required this.nombre,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      id: int.parse(json['id_suc'].toString()),
      nombre: json['nom_suc'],
    );
  }
}

class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String rutaImg;
  final String nombreSucursal;
  final int cantidadDisponible;
  late int inventoryId;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.rutaImg,
    required this.nombreSucursal,
    required this.cantidadDisponible,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: int.parse(json['id_prod'].toString()),
      nombre: json['nom_prod'],
      descripcion: json['desc_prod'],
      precio: double.parse(json['prec_prod'].toString()),
      rutaImg: json['ruta_img'],
      nombreSucursal: json['nom_suc'],
      cantidadDisponible: int.parse(json['exist_prod'].toString()),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final String description;
  final String branchName;
  final int availableQuantity;
  final VoidCallback onTapAddToCart;
  final VoidCallback onTapAddToWishList;

  const ProductCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.description,
    required this.branchName,
    required this.availableQuantity,
    required this.onTapAddToCart,
    required this.onTapAddToWishList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Center(
          // Centrar el contenido del ProductCard
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    topRight: Radius.circular(5.0),
                  ),
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    height: 250.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Precio: \$$price',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Sucursal: $branchName',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Existencia: $availableQuantity pzas',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: onTapAddToCart,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onTapAddToWishList,
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(
                          Icons.favorite_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
