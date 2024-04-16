// ignore_for_file: avoid_print, prefer_const_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:e_commerce/barra_navegacion.dart';
import 'package:e_commerce/historial.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegistroCliente extends StatefulWidget {
  RegistroCliente({Key? key}) : super(key: key);

  @override
  _RegistroClienteState createState() => _RegistroClienteState();
}

class _RegistroClienteState extends State<RegistroCliente> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController noTarjetaController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController rfcController = TextEditingController();
  TextEditingController cpController = TextEditingController();
  TextEditingController colController = TextEditingController();
  TextEditingController calleController = TextEditingController();
  TextEditingController neController = TextEditingController();
  TextEditingController niController = TextEditingController();
  String mensaje = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> guardarDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;

    var response = await http.post(
      Uri.parse('http://localhost:3002/GPO_218/api/apiDatosCliente.php'),
      body: {
        'no_tarjeta': noTarjetaController.text,
        'tel_clie': telController.text,
        'rfc_clie': rfcController.text,
        'cp_clie': cpController.text,
        'col_clie': colController.text,
        'calle_clie': colController.text,
        'ne_clie': neController.text,
        'ni_clie': niController.text,
        'userId': userId.toString(),
      },
    );

    final responseData = json.decode(response.body);
    print('Respuesta: $responseData');

    if (responseData != null) {
      setState(() {
        mensaje = responseData['message'];
      });
      // print('Mensaje: ${responseData['message']}');
      // Registro completado exitosamente
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Éxito',
        desc: 'Registro completado exitosamente',
        btnOkOnPress: () {},
      ).show();
    }

    if (userId != 0) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.info,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: 'Ya tienes una cuenta, porfavor solo confirma tu compra',
        btnOkOnPress: () {},
      ).show();
      return;
    }
  }

  Future<void> confirmarCompra(int userId) async {
    var response = await http.get(
      Uri.parse(
          'http://localhost:3002/GPO_218/api/apiVenta.php?userId=$userId'),
    );

    final responseData = json.decode(response.body);
    print('Respuesta de la compra: $responseData');

    if (responseData != null) {
      if (responseData['mensaje'] == 'Venta realizada con éxito') {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'Éxito',
          desc: 'Compra realizada con éxito',
          btnOkOnPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Historial(),
              ),
            );
          },
        ).show();
      } else {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: 'Error al confirmar la compra',
          btnOkOnPress: () {},
        ).show();
      }
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                shadowColor: Colors.black54,
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _buildTextField(
                              "Número de Tarjeta", noTarjetaController),
                          _buildTextField("Télefono", telController),
                          _buildTextField("RFC", rfcController),
                          _buildTextField("Código postal", cpController),
                          _buildTextField("Colonia", colController),
                          _buildTextField("Calle", calleController),
                          _buildTextField("Número exterior", neController),
                          _buildTextField("Número interior", niController),
                          const SizedBox(height: 10.5),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                guardarDatos();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(6.0, 6.0),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(20.0),
                            ),
                            child: const Text('Guardar datos'),
                          ),
                          const SizedBox(height: 10.5),
                          ElevatedButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              int userId = prefs.getInt('userId') ?? 0;
                              if (userId != 0) {
                                confirmarCompra(userId);
                              } else {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.info,
                                  animType: AnimType.rightSlide,
                                  title: 'Error',
                                  desc:
                                      'No cuentas con un registro de datos, por favor llena el formulario',
                                  btnOkOnPress: () {},
                                ).show();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(5.0, 5.0),
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.all(20.0),
                            ),
                            child: const Text('Confirmar compra'),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 100,
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  mensaje,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF3555F6), width: 2.0),
          ),
        ),
        validator: (value) {
          if (labelText != 'Número de Tarjeta' &&
              (value == null || value.isEmpty)) {
            if (labelText == 'RFC' || labelText == 'Número interior') {
              return null;
            }
            return 'Por favor, ingresa tu $labelText';
          }
          if (labelText == 'Número de Tarjeta') {
            if (value == null || value.isEmpty) {
              return 'Por favor, Ingresa tu $labelText';
            }
            if (!RegExp(r'^[0-9]{13,18}$').hasMatch(value)) {
              return 'Número de tarjeta no válido.\nDebe contener al menos 13 dígitos.';
            }
          }
          if (labelText == 'Télefono') {
            if (!RegExp(r'^[0-9]{8,10}$').hasMatch(value!)) {
              return 'Número de teléfono no válido.\nDebe contener 10 dígitos.';
            }
          }
          if (labelText == 'RFC') {
            if (value!.isNotEmpty && value.length != 12) {
              return 'Formato de RFC no válido.\nDebe contener 12 caracteres alfanuméricos.';
            }
          }
          if (labelText == 'Código postal') {
            if (!RegExp(r'^[0-9]{5}$|^e[0-9]{4}$').hasMatch(value!)) {
              return 'Código postal no válido.\nDebe contener 5 dígitos.';
            }
          }
          if (labelText == 'Número exterior') {
            if (!RegExp(r'^\d{1,4}[a-zA-Z]{0,4}$').hasMatch(value!)) {
              return 'Formato inválido.\nDebe contener al menos un número';
            }
          }
          return null;
        },
        keyboardType:
            TextInputType.number, // Restringir el teclado a solo números
      ),
    );
  }
}
