import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// PROVIDER PARA MOSTRAR LOS DISTRITOS
class ShowDistrictsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _distritos = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get distritos => _distritos;
  bool get isLoading => _isLoading;

  Future<void> fetchDistricts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('http://localhost:5289/api/Districts/show_districts'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _distritos = List<Map<String, dynamic>>.from(data['show_districts']);
        notifyListeners();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
