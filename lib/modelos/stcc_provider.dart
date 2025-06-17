import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class STCCProvider with ChangeNotifier {
  List<Map<String, dynamic>> _stcc = [];
  List<Map<String, dynamic>> _stccFiltrado = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get stcc => _stcc;
  List<Map<String, dynamic>> get stccFiltrado => _stccFiltrado;
  bool get isLoading => _isLoading;

  // Método para agregar STCC
  Future<void> addSTCC(String stcc, String descripcion, String clase, String gs,
      int estatus) async {
    _isLoading = true;
    notifyListeners();
    String url = 'http://10.10.76.150/TrenSeguro/api/saveSTCC';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'STCC': stcc,
          'DESCRIPCION': descripcion,
          'CLASE': clase,
          'GRUPO_SEGREGACION': gs,
          'STATUS': estatus,
        }),
      );

      if (response.statusCode == 200) {
        _stcc.add({
          'STCC': stcc,
          'DESCRIPCION': descripcion,
          'CLASE': clase,
          'GRUPO_SEGREGACION': gs,
          'STATUS': estatus,
        });
        notifyListeners();
      } else {
        throw Exception('Fallo en agregar STCC');
      }
    } catch (e) {
      print('Error al agregar STCC: $e');
      // Aquí lanzas de nuevo el error para que sea capturado en `catchError`
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cargar todos los STCC
  Future<void> mostrarSTCC() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('http://10.10.76.150/TrenSeguro/api/getSTCC'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _stcc = List<Map<String, dynamic>>.from(data['STCC']);
        _stccFiltrado = List.from(_stcc); // Inicialmente mostrar todos
      } else {
        throw Exception('Error al cargar los datos');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para cambiar el estado de un STCC (Activo/Inactivo)
  Future<void> actualizarSTCC(int id, int newStatus) async {
    final url =
        Uri.parse('http://10.10.76.150/TrenSeguro/api/activoInactivoSTCC');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ID': id,
          'STATUS': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('STCC actualizado correctamente');
        // Actualiza localmente el STCC específico
        final index = _stcc.indexWhere((stcc) => stcc['ID'] == id);
        if (index != -1) {
          _stcc[index]['STATUS'] = newStatus;
          notifyListeners();
        }
      } else {
        print('Error al actualizar el STCC: ${response.body}');
        throw Exception('Error al actualizar el STCC');
      }
    } catch (error) {
      print('Error al actualizar STCC: $error');
    }
  }

  // Método para buscar STCC por código o descripción
  void filtrarSTCC(String query) {
    if (query.isEmpty) {
      _stccFiltrado = List.from(_stcc); // Si no hay búsqueda, mostrar todos
    } else {
      _stccFiltrado = _stcc.where((stccItem) {
        final stccCodigo = stccItem['STCC'].toString().toLowerCase();
        final descripcion = stccItem['DESCRIPCION'].toString().toLowerCase();
        return stccCodigo.contains(query.toLowerCase()) ||
            descripcion.contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
