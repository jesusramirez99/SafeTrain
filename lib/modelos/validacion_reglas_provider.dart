import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ValidacionReglasProvider extends ChangeNotifier {
  List<Map<String, dynamic>> reglasIncumplidas = [];
  List<Map<String, dynamic>> reglasValidadas = [];
  bool isLoading = false;
  String errorMessage = '';
  String resultadoMensaje = '';

  // Método principal para validar reglas
  Future<bool> validacionReglas(
    String idTren,
    String estation,
    String validated,
    String userName,
    String estacionActual,
  ) async {
    final url =
        Uri.parse('http://10.10.76.150/TrenSeguroDev/api/ValidarReglas');

    _setLoadingState(true);
    _resetState();

    try {
      final body = _buildRequestBody(
        idTren,
        estation,
        validated,
        userName,
        estacionActual,
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return _handleSuccessResponse(response, idTren);
      } else {
        _setErrorMessage(
          'Error en la solicitud: Código ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      _setErrorMessage('Ocurrió un error: $e');
      return false;
    } finally {
      _setLoadingState(false);
    }
  }

  // Construir el cuerpo de la solicitud
  String _buildRequestBody(
    String idTren,
    String estation,
    String validated,
    String userName,
    String estacionActual,
  ) {
    return jsonEncode({
      'Pending_Train_ID': idTren,
      'Last_Station': estation,
      'Validated_Train': validated,
      'Validated_By': userName,
      'Validated_Date': DateTime.now().toIso8601String(),
      'estacion_actual': estacionActual,
    });
  }

  // Manejar la respuesta exitosa
  bool _handleSuccessResponse(http.Response response, String idTren) {
    final data = jsonDecode(response.body);

    if (data['Reglas']['success'] == true) {
      resultadoMensaje = data['Reglas']['message'] ?? 'Mensaje no disponible';

      if (data['Reglas']['wrapper'].length > 0) {
        final reglas = data['Reglas']['wrapper'] as List;

        _processReglas(reglas);
        return false;
      } else {
        _setErrorMessage(
            'La respuesta del servidor no contiene reglas validadas.');
        return true;
      }

    } else {

      resultadoMensaje = data['Reglas']['message'] ?? 'Mensaje no disponible';
      if (data['Reglas']['wrapper'].length > 0) {
        final reglas = data['Reglas']['wrapper'] as List;
        _processReglas(reglas, soloIncumplidas: true);
        return false;
      }
      return false;
    }
  }

  // Procesar reglas desde el wrapper
  void _processReglas(List reglas, {bool soloIncumplidas = false}) {
    if (!soloIncumplidas) {
      reglasValidadas = reglas
          .where((regla) => regla['ok'] == true)
          .map((regla) => {
                'Regla': regla['Regla'] ?? 'Sin regla',
                'Descripcion': regla['Descripcion'] ?? 'Sin descripción',
              })
          .toList();
    }

    // Procesar reglas incumplidas
    reglasIncumplidas = reglas
        .where((regla) => regla['ok'] == false)
        .map((regla) => {
              'regla': regla['Regla'] ?? 'Regla desconocida',
              'Descripcion': regla['Descripcion'] ?? 'Sin descripción',
              'violaciones': regla['ArrayValidado'],
            })
        .toList();

    notifyListeners();
  }

  // Reiniciar estados previos
  void _resetState() {
    reglasIncumplidas.clear();
    reglasValidadas.clear();
    resultadoMensaje = '';
    errorMessage = '';
  }

  // Actualizar el estado de carga
  void _setLoadingState(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // Establecer mensaje de error
  void _setErrorMessage(String message) {
    errorMessage = message;
    notifyListeners();
  }
}
