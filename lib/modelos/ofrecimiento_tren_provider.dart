import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:safe_train/config/environment.dart';
import 'package:safe_train/modelos/tablas_tren_provider.dart';

class OfrecimientoTrenProvider with ChangeNotifier {
  // FUNCION PARA ACTUALIZAR EL OFRECIMIENTO DEL TREN
  Future<void> ofrecimientoTren({
    required BuildContext context,
    required String tren,
    required String ofrecido,
    required String ofrecidoPor,
    required String fechaOfrecido,
    required String estacion,
  }) async {
    final tablesTrainsProvider =
        Provider.of<TablesTrainsProvider>(context, listen: false);
    final id = tablesTrainsProvider.selectedID;
    print('id:${id}');

    if (id == null || id.isEmpty) {
      throw Exception('El ID del tren no está disponible');
    }

    final url =
        Uri.parse('${Enviroment.baseUrl}/updateOfrecimiento');
    final body = jsonEncode({
      "ID": id,
      "Pending_Train_ID": tren,
      "ofrecido": ofrecido,
      "ofrecido_por": ofrecidoPor,
      "fecha_ofrecido": fechaOfrecido,
      "estacion_actual": estacion,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      print("URL: $url");
      print("Headers: ${{"Content-Type": "application/json"}}");
      print("Body: $body");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['Response']['success'] == true) {
          notifyListeners();
        } else {
          throw Exception(
              responseData['Response']['message'] ?? 'Error desconocido');
        }
      } else {
        print('Response Body: ${response.body}');
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
    } catch (error) {
      print("Error al realizar la solicitud: $error");
      rethrow;
    }
  }
}
