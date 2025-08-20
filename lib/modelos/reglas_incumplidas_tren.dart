import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train/config/environment.dart';
import 'package:safe_train/modelos/reglas_incumplidas_tren_modelo.dart';

// Proveedor para manejar los datos de las reglas incumplidas
class ReglasIncumplidasTrenProvider with ChangeNotifier {
  List<ReglasIncumplidasTren> _reglasIncumplidas = [];
  bool _isLoading = false;

  // Getter para acceder a las reglas incumplidas
  List<ReglasIncumplidasTren> get reglasIncumplidas => _reglasIncumplidas;

  // Getter para el estado de carga
  bool get isLoading => _isLoading;

  // Método para obtener las reglas incumplidas desde la API
  Future<void> fetchReglasIncumplidas(String idTren, String estacion) async {
    _isLoading = true;
    notifyListeners();

    final url =
        '${Enviroment.baseUrl}/getReglaIncumplidaTren?idTren=$idTren&estacion=$estacion';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> reglasData = data['ReglasIncumplidas']['wrapper'];

        // Convertimos los datos a objetos ReglaIncumplida
        _reglasIncumplidas = reglasData
            .map((reglaJson) => ReglasIncumplidasTren.fromJson(reglaJson))
            .toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      throw error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
