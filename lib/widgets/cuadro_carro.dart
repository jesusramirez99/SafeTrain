import 'package:flutter/material.dart';

class CuadroCarro extends StatefulWidget {
  final TextEditingController carroController;

  CuadroCarro({Key? key, required this.carroController}) : super(key: key);

  @override
  State<CuadroCarro> createState() => _CuadroCarroState();
}

class _CuadroCarroState extends State<CuadroCarro> {
  TextEditingController carroController = TextEditingController();

  // Estilo texto del textfield
  InputDecoration decorationText() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 180,
            height: 40.0,
            child: TextField(
              controller: carroController,
              onChanged: (text) {
                carroController.text = text.toUpperCase();
                carroController.selection = TextSelection.fromPosition(
                    TextPosition(offset: carroController.text.length));
              },
              decoration: decorationText().copyWith(
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
