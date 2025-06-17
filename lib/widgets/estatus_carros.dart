import 'package:flutter/material.dart';

class EstatusCarros extends StatefulWidget {
  const EstatusCarros({super.key});

  @override
  State<EstatusCarros> createState() => EstatusCarrosState();
}

const List<String> list = <String>[
  'Seleccione el Estatus',
  'Activo',
  'Inactivo'
];

class EstatusCarrosState extends State<EstatusCarros> {
  String selectedItemEstatus = list.first;

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16.0),
              underline: Container(),
              focusColor: Colors.transparent,
              value: selectedItemEstatus,
              onChanged: (String? value) {
                setState(() {
                  selectedItemEstatus = value!;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: value == 'Seleccione el Estatus'
                      ? Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            value,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade500,
                            ),
                          ),
                        )
                      : Text(value),
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
}
