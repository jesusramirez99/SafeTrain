import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/stcc_provider.dart';

class STCC extends StatefulWidget {
  const STCC({
    super.key,
  });

  @override
  State<STCC> createState() => STCCState();
}

class STCCState extends State<STCC> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController stccController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController claseController = TextEditingController();
  final FocusNode _stccFocusNode = FocusNode();

  String? selectedItemSG = 'Seleccione un GS'; // Valor inicial
  List<String> list = <String>[
    'Seleccione un GS',
    '1',
    '2',
    '3',
    '4',
    '1.6',
    '6.1',
    'N/A',
    'De acuerdo con material de mayor riesgo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  // MODAL STCC
  Future<void> mdlSTCC(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            width: 500.0,
            height: 660.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 15.0),
                      Center(
                        child: Text(
                          'STCC',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 25.0),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 100.0,
                              height: 40.0,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'STCC:',
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
                              child: campoSTCC(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 100.0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Descripción:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7.0),
                            Expanded(
                              child:
                                  campoDescripcion(), // Campo de descripción personalizado
                            ),
                          ],
                        ),
                      ),
                      //const SizedBox(height: 25.0),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .center, // Ajustar según prefieras
                          children: <Widget>[
                            SizedBox(
                              width: 100.0,
                              height: 40.0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Clase:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7.0),
                            Expanded(
                              child: campoClase(),
                            ),
                          ],
                        ),
                      ),
                      // Otras filas aquí
                      const SizedBox(height: 25.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 100.0,
                            height: 40.0,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Grupo\nSegregación:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 7.0),
                          Expanded(
                            child: Container(
                              height: 45.0,
                              //width: 30,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(5.0),
                                // Otras decoraciones que necesites
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 20.0,
                                style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16.0),
                                underline: Container(), // Elimina el subrayado
                                value: selectedItemSG,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedItemSG = newValue;
                                    print(
                                        'Nuevo item seleccionado: $selectedItemSG');
                                  });
                                },
                                items: list.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text(
                                        value,
                                        textAlign: TextAlign.left,
                                        style: value == 'Seleccione un GS'
                                            ? TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade500,
                                              )
                                            : const TextStyle(
                                                color: Colors.black,
                                              ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Expanded(child: Container()),
                      const Divider(),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _btnCancelar(context),
                          _btnRegistrar(context),
                        ],
                      ),
                      const SizedBox(height: 22.0),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ESTILOS DROPDOWN
  Decoration decoracionDropDown() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(4.0),
    );
  }

  // Método _submit
  void _submit(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      String stcc = stccController.text;
      String desc = descController.text;
      String clase = claseController.text;
      String grupoSegregacion = selectedItemSG ?? 'Seleccione un GS';

      Provider.of<STCCProvider>(context, listen: false)
          .addSTCC(stcc, desc, clase, grupoSegregacion, 1)
          .then((_) {
        // Limpiar los campos después de registrar
        stccController.clear();
        descController.clear();
        claseController.clear();

        selectedItemSG = 'Seleccione un GS'; // Resetear el dropdown

        _showFlushbar(context, 'Registro exitoso', Colors.green.shade500);
        FocusScope.of(context)
            .requestFocus(_stccFocusNode); // Foco en el primer campo
      }).catchError((error) {
        print('Error capturado en _submit: $error');
        _showFlushbar(
            context, 'Error al registrar el STCC: $error', Colors.red);
      });
    } else {
      print('se requiere llenar todos los campos');
    }
  }

  // CAMPO STCC
  Widget campoSTCC() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: stccController,
        focusNode: _stccFocusNode,
        keyboardType: TextInputType.number, // Permite solo entrada numérica
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter
              .digitsOnly // Filtra la entrada para que solo se admitan dígitos
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar el STCC';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.inventory_outlined),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13.0,
          ), // Ajustar el espacio vertical dentro del TextFormField
          isDense: true,
        ),
      ),
    );
  }

  // CAMPO DESCRIPCION
  Widget campoDescripcion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 25.0),
      child: TextFormField(
        controller: descController,
        onChanged: (text) {
          descController.text = text.toUpperCase();
          descController.selection = TextSelection.fromPosition(
              TextPosition(offset: descController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar la descripción';
          }
          return null;
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12),
          isDense: true,
        ),
        maxLines: 3,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  // CAMPO CLASE
  Widget campoClase() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 25.0),
      child: TextFormField(
        controller: claseController,
        keyboardType: TextInputType.number, // Permite solo entrada numérica
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter
              .digitsOnly // Filtra la entrada para que solo se admitan dígitos
        ],

        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar el tipo de clase';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.assignment_outlined),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13.0,
          ), // Ajustar el espacio vertical dentro del TextFormField
          isDense: true,
        ),
      ),
    );
  }

  // BOTON REGISTRAR
  Widget _btnRegistrar(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        _submit(context);
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
        children: <Widget>[
          const Icon(Icons.app_registration, color: Colors.green, size: 18.0),
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
        stccController.clear();
        descController.clear();
        claseController.clear();
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
      duration: Duration(seconds: 4),
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
