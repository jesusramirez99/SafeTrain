import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/user_provider.dart';
import 'package:safe_train/pages/login/login_page.dart';

class DropdownFC extends StatefulWidget {
  const DropdownFC({super.key});

  @override
  State<DropdownFC> createState() => _DropdownFCState();
}

class _DropdownFCState extends State<DropdownFC> {
  String? _dropdownValue;

  @override
  void initState() {
    super.initState();
    _dropdownValue = 'FFCC';
  }

  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: const Color.fromRGBO(5, 5, 5, 0.6),
        width: 450.0,
        height: 435.0,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 25.0),
            _logoGMXT(),
            const SizedBox(height: 50.0),
            _titulo(),
            const SizedBox(height: 40.0),
            _comboBoxfc(),
            const SizedBox(height: 20.0),
            _botonIngresar(context), // Ahora paso context aquí
            const Spacer(),
            const Text(
              'Copyright © 2025  |  Digital GMXT® ',
              style: TextStyle(color: Colors.white, fontSize: 10.0),
            ),
          ],
        ),
      ),
    );
  }

  // IMAGEN LOGO GMXT
  Image _logoGMXT() {
    return Image.asset(
      'assets/images/gmxt-logo.png',
      width: 160.0,
      height: 70.0,
      fit: BoxFit.cover,
    );
  }

  // TEXTO TITULO TREN SEGURO
  Text _titulo() {
    return const Text(
      'Tren Seguro',
      style: TextStyle(
          color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w200),
    );
  }

  // DROPDOWN
  Widget _comboBoxfc() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: 200.0,
      height: 55.0,
      child: Consumer<FfccProvider>(
        builder: (context, dropdownProvider, child) {
          return DropdownButtonFormField<String>(
            decoration: _estiloDrop(),
            value: dropdownProvider.selectedItem,
            onChanged: (String? newValue) {
              if (newValue != null && newValue != 'FFCC') {
                dropdownProvider.setSelectedItem(
                    newValue); // Actualiza el valor en el provider
              }
            },
            items: <String>['FFCC', 'FXE', 'FSRR']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                enabled: value != 'FFCC',
                child: Text(
                  value,
                  style: TextStyle(
                    color: value == 'FFCC'
                        ? Colors.blue.shade600
                        : Colors.grey.shade600,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  InputDecoration _estiloDrop() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // Botón Ejecutar
  Widget _botonIngresar(BuildContext context) {
    return Consumer<FfccProvider>(
      builder: (context, dropdownProvider, child) {
        return ElevatedButton(
          onPressed: () {
            if (dropdownProvider.selectedItem == 'FFCC') {
              Flushbar(
                duration: const Duration(seconds: 4),
                backgroundColor: Colors.red,
                flushbarPosition: FlushbarPosition.TOP,
                margin: const EdgeInsets.all(1.0),
                borderRadius: BorderRadius.circular(5.0),
                messageText: const Text(
                  'Por favor, seleccione un FFCC válido.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ).show(context);
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const Login(),
                ),
                (Route<dynamic> route) => false,
              );
            }
            print('Ingresar');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(235, 114, 146, 251),
            padding: const EdgeInsets.symmetric(
              horizontal: 55.0,
              vertical: 10.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          child: const Text(
            'Ingresar',
            style: TextStyle(color: Colors.white, fontSize: 12.0),
          ),
        );
      },
    );
  }
}
