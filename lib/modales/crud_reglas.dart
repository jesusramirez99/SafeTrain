import 'package:flutter/material.dart';
import 'package:safe_train/widgets/estatus_carros.dart';

class Reglas extends StatefulWidget {
  final TextEditingController reglasController;
  final TextEditingController tipoController;
  final TextEditingController descController;
  const Reglas(
      {super.key,
      required this.reglasController,
      required this.tipoController,
      required this.descController});

  @override
  State<Reglas> createState() => ReglasState();
}

class ReglasState extends State<Reglas> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController reglasController = TextEditingController();
  final TextEditingController tipoController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  String selectedItemEstatus = list.first;
  String? _selectedStatus = 'Seleccione el Estatus';
  List<String> listStatus = <String>[
    'Seleccione el Estatus',
    'Activo',
    'Inactivo',
  ];

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(),
    );
  }

  // MODAL REGLAS
  Future<void> mdlReglas(BuildContext context) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            width: 500.0, // Ajustado para coincidir con el ancho del otro modal
            height: 600.0, // Ajustado para mantener proporciones
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
                          'Reglas',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 15.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            width: 100.0,
                            height: 40.0,
                            child: Text(
                              'Regla:',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7.0),
                          Expanded(child: campoRegla()),
                        ],
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SizedBox(
                            width: 100.0,
                            height: 60.0,
                            child: Text(
                              'Tipo:',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7.0),
                          Expanded(child: campoTipo()),
                        ],
                      ),
                      const SizedBox(height: 10.0),
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
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 7.0),
                            Expanded(child: campoDescripcion()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 100.0,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Estatus:',
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
                            child: Container(
                              height: 45.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                iconSize: 20.0,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16.0,
                                ),
                                underline: Container(),
                                value: _selectedStatus,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedStatus = newValue;
                                    print(
                                        'Nuevo item seleccionado: $_selectedStatus');
                                  });
                                },
                                items: listStatus.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 12.0),
                                      child: Text(
                                        value,
                                        textAlign: TextAlign.left,
                                        style: value == 'Seleccione el Estatus'
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
                      const SizedBox(height: 30.0),
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

  void _submit() {
    if (formKey.currentState!.validate()) {
      print('submit');
    }
  }

  // CAMPO CARRO
  Widget campoRegla() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: reglasController,
        onChanged: (text) {
          reglasController.text = text.toUpperCase();
          reglasController.selection = TextSelection.fromPosition(
              TextPosition(offset: reglasController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar la regla';
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

  // CAMPO CARRO
  Widget campoTipo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 25.0),
      child: TextFormField(
        controller: tipoController,
        onChanged: (text) {
          tipoController.text = text.toUpperCase();
          tipoController.selection = TextSelection.fromPosition(
              TextPosition(offset: tipoController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar el tipo de regla';
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

  // CAMPO DESCRIPCION
  Widget campoDescripcion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 25.0),
      child: TextFormField(
        controller: descController,
        onChanged: (text) {},
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
        maxLines: 2,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  // BOTON REGISTRAR
  Widget _btnRegistrar(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        _submit();

        reglasController.clear();
        tipoController.clear();
        descController.clear();
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
        reglasController.clear();
        tipoController.clear();
        descController.clear();
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

  /*
  // DROPDOWN ESTATUS
  Widget dropDownEstatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: decoracionDropDown(),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 200.0,
            height: 40.0,
            child: DropdownButton<String>(
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 20.0,
              elevation: 16,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16.0),
              underline: Container(),
              value: selectedItemEstatus,
              onChanged: (String? value) {
                setState(() {
                  selectedItemEstatus = value!;
                  print(selectedItemEstatus);
                  print(value);
                });
                print(selectedItemEstatus);
                print(value);
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ESTILOS DROPDOWN
  Decoration decoracionDropDown() {
    return BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(4.0),
    );
  }
  */
}
