import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OfferedTrainProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Método para verificar si el tren ya está ofrecido
  Future<bool> checkTrainOffered(String trainId) async {
    final url = Uri.parse(
        'http://localhost:5001/safe_train/check_train_offered?Pending_Train_ID=$trainId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'already_offered') {
          print('El tren ya está ofrecido');
          return true;
        } else {
          print('El tren aún no está ofrecido');
          return false;
        }
      } else {
        _errorMessage =
            'Error al verificar el tren ofrecido: ${response.statusCode}';
        print(_errorMessage);
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      print('Error al verificar si el tren está ofrecido: $_errorMessage');
      return false;
    }
  }
}
