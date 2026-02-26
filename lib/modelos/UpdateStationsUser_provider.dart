import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train/config/environment.dart';

class UpdatestationsuserProvider with ChangeNotifier {

  Future<Map<String, dynamic>> updateEstacionesUser (
    int userId,
    List<Map<String, String>> estaciones,
  )async {

    try{
      final uri = Uri.parse('${Enviroment.baseUrl}/updateEstacionesUser?userId=$userId');
        final response = await http.put(uri, headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(estaciones),
      );
      final decoded = json.decode(response.body);

      if(response.statusCode == 200){
        return{
          "success": decoded["Response"]?["success"] ?? false,
          "message": decoded["Response"]?["message"] ?? "Estaciones actualizadas correctamente"
        };
      }else{
        return{
          "success": false,
          "message": "Error del servidor: ${response.statusCode}"
        };
      }
    }catch(e){
      return{
        "success": false,
        "message": "Error inesperado: $e"
      };
    }finally{}
  }
}