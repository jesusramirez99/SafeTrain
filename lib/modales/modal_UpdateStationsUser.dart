import 'package:flutter/material.dart';

class ModalUpdatestationsuser extends StatefulWidget {
  final int userId;
  const ModalUpdatestationsuser({super.key, required this.userId});

  @override
  State<ModalUpdatestationsuser> createState() => ModalUpdatestationsuserState();
}

class ModalUpdatestationsuserState extends State<ModalUpdatestationsuser> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 550,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Actualizar estaciones',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Cerrar")
            ),
          ],
        ),
      ),
    );
  }

  

}