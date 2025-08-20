import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:safe_train/config/environment.dart';

// PROVIDER PARA MOSTRAR LOS CARROS TENDER
class TenderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _carrosTender = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get carrosTender => _carrosTender;
  bool get isLoading => _isLoading;

  // FUNCION PARA MOSTRAR LOS CARROS TENDER
  Future<void> mostrarTender() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse('${Enviroment.baseUrl}/getCarrosTender'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _carrosTender = List<Map<String, dynamic>>.from(data['CarrosTender']);
        notifyListeners(); // Notifica a los listeners
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

  // FUNCION PARA AGREGAR CARROS TENDER
  Future<void> addTender(
      String carro,
      String description,
      String? updatedBy,
      String updateDate,
      String? createdBy,
      String recordDate,
      int status) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${Enviroment.baseUrl}/saveCarrosTender'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name_car': carro,
          'description': description,
          'updated_by': updatedBy,
          'update_date': updateDate,
          'created_by': createdBy,
          'record_date': recordDate,
          'status': status
        }),
      );

      if (response.statusCode == 200) {
        // Si la solicitud fue exitosa, agrega el nuevo carro tender a la lista local
        _carrosTender.add({
          'name_car': carro,
          'description': description,
          'updated_by': updatedBy,
          'update_date': updateDate,
          'created_by': createdBy,
          'record_date': recordDate,
          'status': status
        });
        notifyListeners();
      } else {
        throw Exception('Failed to insert carro tender');
      }
    } catch (e) {
      print('Error en agregar carro tender: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PROVIDER PARA ACTUALIZAR EL ESTADO (ACTIVO / INACTIVO) DE UN CARRO TENDER
  Future<void> actualizarTender(
      int idTender, String user, String date, int newStatus) async {
    final url =
        Uri.parse('${Enviroment.baseUrl}/updateCarrosTender');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ID': idTender,
          'UPDATED_BY': user,
          'UPDATED_DATE': date,
          'STATUS': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('carro Tender actualizado correctamente');
        // Actualiza localmente el TENDER específico
        final index = _carrosTender
            .indexWhere((carrosTender) => carrosTender['ID'] == idTender);
        if (index != -1) {
          _carrosTender[index]['STATUS'] = newStatus;
          notifyListeners();
        }
      } else {
        print('Error al actualizar el carro tender: ${response.body}');
        throw Exception('Error al actualizar el Carro Tender');
      }
    } catch (error) {
      print('Error al actualizar STCC: $error');
    }
  }
}

/*
// PROVIDER PARA ACTUALIZAR A INACTIVO LOS CARROS TENDER
class UpdateToInactiveTenderProvider with ChangeNotifier {
  Future<void> updateCarTender(
      int idCar, String user, String date, int newStatus) async {
    final url =
        Uri.parse('http://localhost:5001/safe_train/update_toinactive_tender');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_car': idCar,
          'update_by': user,
          'update_date': date,
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        // Actualización exitosa
        print('Carro actualizado correctamente');
      } else {
        // Error en la solicitud
        print('Error al actualizar el carro: ${response.body}');
      }
    } catch (error) {
      // Manejo de errores
      print('Error al actualizar carro: $error');
    }
  }
}
*/
// PROVIDER PARA ACTUALIZAR A ACTIVO LOS CARROS TENDER
class UpdateToActiveTenderProvider with ChangeNotifier {
  Future<void> updateCarTender(
      int idCar, String user, String date, int newStatus) async {
    final url =
        Uri.parse('http://localhost:5001/safe_train/update_toactive_tender');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_car': idCar,
          'update_by': user,
          'update_date': date,
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        // Actualización exitosa
        print('Carro actualizado correctamente');
      } else {
        // Error en la solicitud
        print('Error al actualizar carro: ${response.body}');
      }
    } catch (error) {
      // Manejo de errores
      print('Error al actualizar carro: $error');
    }
  }
}
