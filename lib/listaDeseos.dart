// ignore_for_file: avoid_print, library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'dart:convert';

import 'package:e_commerce/barra_navegacion.dart';
import 'package:e_commerce/carrito.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ListaDeseos extends StatefulWidget {
  const ListaDeseos({Key? key}) : super(key: key);

  @override
  _ListaDeseosState createState() => _ListaDeseosState();
}

class _ListaDeseosState extends State<ListaDeseos> {
  List<dynamic> wishListItems = [];
  late bool hasItems;

  @override
  void initState() {
    super.initState();
    hasItems = false;
    fetchListData();
  }

  Future<Map<String, dynamic>> fetchListData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;
    String url =
        'http://localhost:3002/GPO_218/api/apiShowWishList.php?userId=$userId';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Error al obtener la lista de deseos');
    }
  }

  void reloadPage() {
    setState(() {});
  }

  Future<void> addToCart(int inventoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;

    final response = await http.post(
      Uri.parse('http://localhost:3002/GPO_218/api/addCarritoWishList.php'),
      body: {
        'userId': userId.toString(),
        'id_inv': inventoryId.toString(),
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          reloadPage();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto añadido a su carrito."),
            backgroundColor: Color(0xFF2EAAEC),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto no añadido a su carrito."),
            backgroundColor: Color(0xFF2EAAEC),
          ),
        );
      }
    } else {
      throw Exception('Error al agregar producto al carrito');
    }
  }

  Future<void> removeFromWishList(int inventoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;
    String url =
        'http://localhost:3002/GPO_218/api/deleteWishList.php?userId=$userId&inventarioId=$inventoryId';

    var response = await http.delete(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        setState(() {
          reloadPage();
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Carrito(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Producto eliminado de su Lista de deseos."),
            backgroundColor: Color(0xFF2EAAEC),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Asegurate de tener conexíon a internet!"),
            backgroundColor: Color.fromARGB(222, 231, 62, 50),
          ),
        );
      }
    } else {
      throw Exception('El producto no se pudo eliminar del carrito.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 10,
          title: const Row(
            children: [
              BottomNav(),
              Spacer(),
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchListData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> listData = snapshot.data!;
              List<dynamic> listItems = listData['ListItems'] ?? [];
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listItems.map((item) {
                            int productId = item['id_prod'];
                            int existenciaInventarios = item['exist_prod'] ?? 0;
                            int inventoryId = item['id_inv'];
                            int idLista = item['id_lista'];
                            return buildProductItem(
                              item['nom_prod'],
                              item['desc_prod'],
                              item['ruta_img'],
                              item['prec_prod'],
                              item['nom_suc'],
                              existenciaInventarios,
                              idLista,
                              productId,
                              inventoryId,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget buildProductItem(
    String? name,
    String? description,
    String? imagePath,
    dynamic price,
    String? branch,
    int existenciaInventarios,
    int productId,
    int cartId,
    int inventoryId,
  ) {
    double? priceDouble;
    if (price is String) {
      priceDouble = double.tryParse(price);
    } else if (price is num) {
      priceDouble = price.toDouble();
    } else {
      priceDouble = null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5.0),
              topRight: Radius.circular(5.0),
            ),
            child: Image.network(
              imagePath ?? '',
              fit: BoxFit.cover,
              height: 100.0,
              width: 150.0,
            ),
          ),
          const SizedBox(width: 18.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? '',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  description ?? '',
                  style: const TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  priceDouble != null
                      ? '\$${priceDouble.toStringAsFixed(2)}'
                      : 'xx.xx.xx',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sucursal: $branch',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                        Text(
                          'Existencias: $existenciaInventarios',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            removeFromWishList(inventoryId);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () async {
                        addToCart(inventoryId);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
