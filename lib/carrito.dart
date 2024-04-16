// ignore_for_file: unused_local_variable, avoid_print, library_private_types_in_public_api, unnecessary_string_interpolations, prefer_const_declarations, camel_case_types, use_build_context_synchronously
import 'dart:convert';

import 'package:e_commerce/formularioCliente.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_commerce/barra_navegacion.dart';

class Carrito extends StatefulWidget {
  const Carrito({Key? key}) : super(key: key);

  @override
  _CarritoState createState() => _CarritoState();
}

class _CarritoState extends State<Carrito> {
  Map<int, int> quantities = {};
  Map<int, int> inventario = {};

  Future<Map<String, dynamic>> fetchCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;

    var response = await http.get(Uri.parse(
        'http://localhost:3002/GPO_218/api/apiShowCart.php?userId=$userId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Error al obtener datos del carrito');
    }
  }

  double calculateSubtotal(List<dynamic> cartItems) {
    double subtotal = 0;
    for (var item in cartItems) {
      double costoProd = double.parse(item['costo_prod']);
      int quantity = item['cant_prod'];
      subtotal += costoProd * quantity * 1.5;
    }
    return subtotal;
  }

  double calculateIva(List<dynamic> cartItems) {
    double subtotal = calculateSubtotal(cartItems);
    double iva = 0;
    for (var item in cartItems) {
      double costoProd = double.parse(item['costo_prod']);
      int quantity = item['cant_prod'];
      iva += costoProd * 1.5 * 0.16 * quantity;
    }
    return iva;
  }

  double calculateTotal(List<dynamic> cartItems) {
    double subtotal = calculateSubtotal(cartItems);
    double iva = calculateIva(cartItems);
    double total = subtotal + iva;
    return total;
  }

  void reloadPage() {
    setState(() {});
  }

  Future<void> removeFromCart(int inventoryId, int cartId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;

    var response = await http.delete(
        Uri.parse(
            'http://localhost:3002/GPO_218/api/deleteCarrito.php?userId=$userId&caritoId=$cartId&inventarioId=$inventoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        });

    if (response.statusCode == 200) {
      setState(() {
        reloadPage();
      });
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('message'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        throw Exception('El producto no se pudo eliminar del carrito.');
      }
    }
  }

  Future<void> updateCartQuantity(int cartId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;

    String url =
        'http://localhost:3002/GPO_218/api/updateCarrito.php?userId=$userId&cartId=$cartId&cant_prod=$quantity';

    var response = await http.post(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    });

    if (response.statusCode == 200) {
      print('Cantidad actualizada correctamente');
      setState(() {});
    } else {
      throw Exception('Error al actualizar la cantidad en el carrito');
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
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchCartData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> cartData = snapshot.data!;
              List<dynamic> cartItems = cartData['cartItems'] ?? [];
              double subtotal = calculateSubtotal(cartItems);
              double total = calculateTotal(cartItems);
              double iva = total - subtotal;
              return Column(
                children: [
                  buildTotalSection(subtotal, iva, total),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        int productId = item['id_prod'];
                        int quantity = item['cant_prod'];
                        int existenciaInventario = item['exist_prod'] ?? 0;
                        int inventoryId = item['id_inv'];
                        int cartId = item['id_carr'];
                        return buildProductItem(
                            item['nom_prod'],
                            item['desc_prod'],
                            item['ruta_img'],
                            item['prec_prod'],
                            item['nom_suc'],
                            item['costo_prod'],
                            existenciaInventario,
                            productId,
                            cartId,
                            quantity,
                            inventoryId,
                            quantity);
                      },
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
      dynamic costoProd,
      int existenciaInventario,
      int productId,
      int cartId,
      int quantity,
      int inventoryId,
      int cantProd) {
    double? priceDouble;
    double? costoProdDouble;
    if (price is String) {
      priceDouble = double.tryParse(price);
    } else if (price is num) {
      priceDouble = price.toDouble();
    } else {
      priceDouble = null;
    }

    if (costoProd is String) {
      costoProdDouble = double.tryParse(costoProd);
    } else if (costoProd is num) {
      costoProdDouble = costoProd.toDouble();
    } else {
      costoProdDouble = null;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4.0),
              topRight: Radius.circular(4.0),
            ),
            child: Image.network(
              imagePath ?? '',
              fit: BoxFit.cover,
              width: 120.0,
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
                const SizedBox(height: 5.0),
                Text(
                  description ?? '',
                  style: const TextStyle(
                    fontSize: 17.0,
                  ),
                ),
                const SizedBox(height: 5.0),
                Text(
                  priceDouble != null
                      ? '\$${priceDouble.toStringAsFixed(2)}'
                      : 'Producto no encontrado',
                  style: const TextStyle(
                    fontSize: 17.0,
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
                          style: const TextStyle(fontSize: 17.0),
                        ),
                        Text(
                          'Existencias: $existenciaInventario',
                          style: const TextStyle(fontSize: 17.0),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        removeFromCart(inventoryId, cartId);
                      },
                    ),
                    IconButton(
                        onPressed: () {
                          if (quantity <= existenciaInventario.toInt() + 1) {
                            setState(() {
                              quantities[quantity] = quantity - 1;
                              inventario[inventoryId] = inventoryId;
                            });
                            updateCartQuantity(cartId, quantity - 1);
                            ScaffoldMessenger.of(context)
                                .showMaterialBanner(const MaterialBanner(
                              content: Text(
                                  'No puedes tener 0 productos CDMX PASTEL BLUEVELVET 22 EXISTENCIAS '),
                              actions: [AlertDialog.adaptive()],
                            ));
                          } else {}
                        },
                        icon: const Icon(Icons.remove, size: 24.0)),
                    Text('$quantity', style: const TextStyle(fontSize: 25.0)),
                    IconButton(
                        onPressed: () {
                          if (quantity > 1 ||
                              quantity <= existenciaInventario.toInt() - 1) {
                            setState(() {
                              quantities[quantity] = quantity + 1;
                              inventario[inventoryId] = inventoryId;
                            });
                            updateCartQuantity(cartId, quantity + 1);
                            print(inventario);
                          } else {}
                        },
                        icon: const Icon(Icons.add, size: 24.0)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTotalSection(double subtotal, double iva, double total) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 25.0,
                  ),
                  children: [
                    const TextSpan(text: 'Subtotal: '),
                    WidgetSpan(
                      child: SizedBox(
                        width: 100, // Adjust size as needed
                        child: Text(
                          '\$${subtotal.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  children: [
                    const TextSpan(text: 'IVA (16%):  '),
                    WidgetSpan(
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          '\$${iva.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  children: [
                    const TextSpan(text: 'Total:   '),
                    WidgetSpan(
                      child: SizedBox(
                        width: 100, // Adjust size as needed
                        child: Text(
                          '\$${total.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RegistroCliente();
                    });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 50.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text(
                'Comprar ahora',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
