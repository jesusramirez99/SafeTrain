import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Fecha extends StatefulWidget {
  final bool isEnabled;
  final TextEditingController fechaController;

  const Fecha(
      {Key? key, required this.fechaController, required this.isEnabled})
      : super(key: key);

  @override
  State<Fecha> createState() => FechaState();
}

class FechaState extends State<Fecha> {
  // final TextEditingController fechaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 165,
            height: 55.0,
            child: TextFormField(
              showCursor: false,
              controller: widget.fechaController,
              enabled: widget.isEnabled,
              onTap: () async {
                // Espera la selección de la fecha
                final DateTime? picked = await _selectDate(context);
                if (picked != null) {
                  // Formatea la fecha como string en el formato deseado
                  String formattedDate =
                      DateFormat('dd-MM-yyyy').format(picked);
                  // Actualiza el texto del TextField
                  setState(() {
                    widget.fechaController.text = formattedDate;
                  });
                }
              },
              decoration: InputDecoration(
                errorStyle: TextStyle(height: 1, color: Colors.red.shade100),
                filled: true,
                fillColor:
                    widget.isEnabled ? Colors.white : Colors.grey.shade300,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.grey),
                  onPressed: () async {
                    // Espera la selección de la fecha
                    final DateTime? picked = await _selectDate(context);
                    if (picked != null) {
                      String formattedDate =
                          DateFormat('dd-MM-yyyy').format(picked);

                      setState(() {
                        widget.fechaController.text = formattedDate;
                      });
                    }
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ingresa una fecha válida';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2050),
    );
    return picked;
  }
}
