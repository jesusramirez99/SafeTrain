import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExportConsistProvider with ChangeNotifier {
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> exportConsist(String tipo, Uint8List fileBytes, String fileName) async {
  _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse('http://10.10.76.150/TrenSeguroDev/api/upload-excel');

      final request = http.MultipartRequest('POST', uri)
        ..fields['tipo'] = tipo
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName,
          ),
        );

      final exportResponse = await request.send();
      final response = await http.Response.fromStream(exportResponse);

      if (response.statusCode == 200) {
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Error de carga de consist: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error de carga de consist: $e';
    }

    notifyListeners();
    return false;
  }

} 
