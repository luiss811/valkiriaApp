// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:e_commerce/barra_navegacion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Historial extends StatefulWidget {
  const Historial({Key? key}) : super(key: key);

  @override
  _HistorialState createState() => _HistorialState();
}

class _HistorialState extends State<Historial> {
  List<dynamic> historial = [];

  @override
  void initState() {
    super.initState();
    obtenerHistorial();
  }

  Future<void> obtenerHistorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;

    var url = Uri.parse(
        'http://localhost:3002/GPO_218/api/ShowHistorial.php?userId=$userId');

    var respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      setState(() {
        historial = json.decode(respuesta.body);
      });
    } else {
      throw Exception('Fallo al cargar el historial de compras');
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
            ],
          ),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: historial.map((compra) {
                return buildPurchaseCard(
                  compra['ruta_img'],
                  compra['nom_prod'],
                  compra['desc_prod'],
                  compra['fechaVenta'],
                  'Cantidad: ${compra['cant_ped']} unidades',
                  'Precio: \$${compra['prec_prod']}',
                  compra['nom_suc'],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPurchaseCard(
    String imagePath,
    String title,
    String description,
    String date,
    String price,
    String quantity,
    String branch,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        child: Row(
          children: [
            Image.network(
              imagePath,
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(description), // Mostrar descripción del producto
                Text('Fecha: $date'),
                Text(price),
                Text(branch),
                Text(quantity),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
