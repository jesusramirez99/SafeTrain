import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train/config/environment.dart';

class RegionDivisionEstacionProvider extends ChangeNotifier {
  // Provider para mostrar los roles de los usuarios
  List<Map<String, dynamic>> _roles = [];

  List<Map<String, dynamic>> get roles => _roles;

  void clearRoles() {
    _roles = [];
    notifyListeners();
  }

  Future<void> fetchRoles() async {
    final url = Uri.parse("${Enviroment.baseUrl}/getRoles");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['Roles'] != null) {
          _roles = (data['Roles'] as List)
          .map((item) => {
                'id': item['ID'],
               'rol': item['Rol'],
              })
          .toList();
          notifyListeners();
        } else {
          debugPrint("La clave 'Rol' no se encontró en la respuesta.");
        }
      } else {
        debugPrint('Error: ${response.statusCode}');
        throw Exception('Error al obtener los Roles');
      }
    } catch (error) {
      debugPrint('Error en fetchRoles: $error');
    }
  }

  // Provider para mostrar las regiones
  List<String> _regiones = [];

  List<String> get regiones => _regiones;

  void clearRegiones() {
    _regiones = [];
    notifyListeners();
  }

  Future<void> fetchRegiones() async {
    final url = Uri.parse('${Enviroment.baseUrl}/getRegiones');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['Regiones'] != null) {
          _regiones = List<String>.from(data['Regiones']);

          notifyListeners();
        } else {
          debugPrint("La clave 'Regiones' no se encontró en la respuesta.");
        }
      } else {
        debugPrint("Error: ${response.statusCode}");
        throw Exception('Error al obtener regiones');
      }
    } catch (error) {
      debugPrint('Error en fetchRegiones: $error');
    }
  }

  // Provider para mostrar las divisiones
  List<String> _divisiones = [];

  List<String> get divisiones => _divisiones;

  void clearDivisiones() {
    _divisiones = [];
    notifyListeners();
  }

  Future<void> fetchDivisiones({required String region}) async {
    final String url =
        "${Enviroment.baseUrl}/getDivisiones?region=$region";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse.containsKey("Divisiones")) {
          _divisiones = List<String>.from(jsonResponse["Divisiones"]);

          notifyListeners();
        } else {
          debugPrint("La clave 'Divisiones' no se encontró en la respuesta.");
        }
      } else {
        debugPrint("Error en la petición: ${response.statusCode}");
      }
    } catch (error) {
      debugPrint("Error al realizar fetchDivisiones: $error");
    }
  }

  // Provider para mostrar las estaciones
  List<String> _estaciones = [];

  List<String> get estaciones => _estaciones;

  // Método opcional para limpiar la lista de estaciones.
  void clearEstaciones() {
    _estaciones = [];
    notifyListeners();
  }

  Future<void> fetchEstaciones({required String division}) async {
    // Construimos la URL utilizando el parámetro de división.
    final String url =
        "${Enviroment.baseUrl}/getEstaciones?division=$division";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Verificamos que el JSON contenga la clave "Estaciones".
        if (jsonResponse.containsKey("Estaciones")) {
          _estaciones = List<String>.from(jsonResponse["Estaciones"]);
          debugPrint("Estaciones obtenidas: $_estaciones");
          notifyListeners(); // Actualiza los widgets consumidores.
        } else {
          debugPrint("La clave 'Estaciones' no se encontró en la respuesta.");
        }
      } else {
        debugPrint("Error en la petición: ${response.statusCode}");
      }
    } catch (error) {
      debugPrint("Error al realizar fetchEstaciones: $error");
    }
  }
}
