import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItinerarioProvider with ChangeNotifier {
  List<Map<String, dynamic>> _itinerarios = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get itinerarios => _itinerarios;
  bool get isLoading => _isLoading;

  Future<void> mostrarItinerario(String idTren) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
        'http://10.10.76.150/TrenSeguroDev/api/obtenerItinerario?idTren=$idTren');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final itinerariosData = data['Itinerario'] as List;

        _itinerarios = List<Map<String, dynamic>>.from(itinerariosData);
        _isLoading = false;
        notifyListeners();
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception('Error al obtener itinerarios');
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      throw error;
    }
  }
}
