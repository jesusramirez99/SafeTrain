import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/cars_open_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';

class CarrosAbiertos extends StatefulWidget {
  const CarrosAbiertos({
    super.key,
  });

  @override
  State<CarrosAbiertos> createState() => CarrosAbiertosState();

  static final GlobalKey<CarrosAbiertosState> carrosAbiertosKey =
      GlobalKey<CarrosAbiertosState>();
}

class CarrosAbiertosState extends State<CarrosAbiertos> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final bool _isLoading = false;
  final FocusNode _carroFocusNode = FocusNode();
  final TextEditingController _carroAbiertoController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> mdlCarrosAbiertos(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            width: 480.0,
            height: 420.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 14.0),
                    Center(
                      child: Text(
                        'Carros Abiertos',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 20.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                          width: 120.0,
                          child: Align(
                            alignment: Alignment
                                .topLeft, // Alinea el texto en la parte superior
                            child: Text(
                              'Carro:',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7.0),
                        Expanded(
                          child: campoCarro(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        SizedBox(
                          width: 120.0,
                          child: Align(
                            alignment: Alignment
                                .topLeft, // Alinea el texto en la parte superior
                            child: Text(
                              'Descripción:',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7.0),
                        Expanded(
                          child: campoDescripcion(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25.0),
                    ///////////////////////////////////////////////////
                    const Divider(),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _btnCancelar(context),
                        const SizedBox(width: 25.0),
                        _btnRegistrar(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget campoCarro() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        focusNode: _carroFocusNode,
        controller: _carroAbiertoController,
        onChanged: (text) {
          _carroAbiertoController.text = text.toUpperCase();
          _carroAbiertoController.selection = TextSelection.fromPosition(
              TextPosition(offset: _carroAbiertoController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Favor de ingresar el carro';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.directions_railway),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 13.0),
          isDense: true,
        ),
      ),
    );
  }

  Widget campoDescripcion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: _descController,
        onChanged: (text) {
          _descController.text = text.toUpperCase();
          _descController.selection = TextSelection.fromPosition(
              TextPosition(offset: _descController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Favor de ingresar la descripción';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.format_list_bulleted),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 13.0),
          isDense: true,
        ),
        maxLines: 4,
      ),
    );
  }

  // LIMPIAR FORMULARIO
  void clearFields() {
    _carroAbiertoController.clear();
    _descController.clear();
  }

  // BOTON REGISTRAR
  Widget _btnRegistrar(BuildContext context) {
    final dateTime = DateTime.now().toIso8601String();
    final user = Provider.of<UserProvider>(context, listen: false).userName;

    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () async {
              if (formKey.currentState!.validate()) {
                // Llamar la funcion desde el provider
                final carro = _carroAbiertoController.text.trim();
                final descripcion = _descController.text.trim();

                await Provider.of<CarsOpenProvider>(context, listen: false)
                    .addOpenCar(
                        carro, descripcion, user, dateTime, user, dateTime, 1);

                // Mostrar el Flushbar
                _showFlushbar(
                    context, 'Registro exitoso', Colors.green.shade500);
                print('Registro exitoso');
                clearFields();

                FocusScope.of(context).requestFocus(_carroFocusNode);
              } else {
                print('Llene el formulario');
                //_showFlushbar(context, 'Llene el formulario', Colors.red);
              }
            },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.app_registration, color: Colors.grey.shade700, size: 18.0),
          const SizedBox(width: 5.0),
          Text(
            'Registrar',
            style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // BOTON CANCELAR
  Widget _btnCancelar(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        Navigator.of(context).pop();
        _carroAbiertoController.clear();
        _descController.clear();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            Colors.grey.shade300), // Color de fondo del botón
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.cancel, color: Colors.red.shade400, size: 18.0),
          const SizedBox(width: 5.0),
          Text(
            'Cancelar',
            style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // MESSAGE FLUSHBAR

  void _showFlushbar(
      BuildContext context, String message, Color backgroundColor) {
    Flushbar(
      duration: const Duration(seconds: 4),
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }
}
