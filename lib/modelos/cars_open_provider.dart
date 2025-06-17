import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:safe_train/modales/crud_carros_abiertos.dart';

// PROVIDER PARA MOSTRAR LOS CARROS ABIERTOS
class CarsOpenProvider with ChangeNotifier {
  List<Map<String, dynamic>> _carrosAbiertos = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get carrosAbiertos => _carrosAbiertos;

  bool get isLoading => _isLoading;

  Future<void> mostrarCarrosAbiertos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
          Uri.parse('http://10.10.76.150/TrenSeguro/api/getCarrosAbiertos'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _carrosAbiertos = List<Map<String, dynamic>>.from(data['show_cars']);
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

  // FUNCION PARA AGREGAR CARROS ABIERTOS
  Future<void> addOpenCar(
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
        Uri.parse('http://10.10.76.150/TrenSeguro/api/saveCarrosAbiertos'),
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
        // Si la solicitud fue exitosa, agrega el nuevo carro abierto a la lista local
        _carrosAbiertos.add({
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
        throw Exception('Failed to insert carro abierto');
      }
    } catch (e) {
      print('Error inserting carro abierto: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // PROVIDER PARA ACTUALIZAR EL ESTADO (ACTIVO / INACTIVO) DE UN CARRO ABIERTO
  Future<void> estatusCarrosAbiertos(
      int idCarOpen, String user, String date, int newStatus) async {
    final url =
        Uri.parse('http://10.10.76.150/TrenSeguro/api/updateCarrosAbiertos');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'ID': idCarOpen,
          'UPDATED_BY': user,
          'UPDATED_DATE': date,
          'STATUS': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        print('carro abierto actualizado correctamente');
        // Actualiza localmente el carro abierto específico
        final index = _carrosAbiertos
            .indexWhere((carrosAbiertos) => carrosAbiertos['ID'] == idCarOpen);
        if (index != -1) {
          _carrosAbiertos[index]['STATUS'] = newStatus;
          notifyListeners();
        }
      } else {
        print('Error al actualizar el carro abierto: ${response.body}');
        throw Exception('Error al actualizar el Carro Abierto');
      }
    } catch (error) {
      print('Error al actualizar STCC: $error');
    }
  }
}

/*
// PROVIDER PARA ACTUALIZAR A ACTIVO LOS CARROS ABIERTOS
class UpdateToActiveOpenProvider with ChangeNotifier {
  Future<void> updateCarOpen(
      int idCar, String user, String date, int newStatus) async {
    final url =
        Uri.parse('http://localhost:5001/safe_train/update_toactive_open');

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
*/