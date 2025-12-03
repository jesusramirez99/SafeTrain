import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_train/config/environment.dart';
import 'dart:convert';


class AdduserProvider with ChangeNotifier {
  bool _isloading = false;
  bool get isloading => _isloading;

  Future<Map<String, dynamic>> addUser(
    String username,
    String name,
    String email,
    int    roleId,
    List<Map<String, String?>> estaciones,
    ) async {
      _isloading = true;
      notifyListeners();
      try{
          final response = await http.post(
              Uri.parse('${Enviroment.baseUrl}/guardarUsuario'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'username': username,
                'nombre': name,
                'email': email,
                'roleId': roleId,
                'ESTACIONES': estaciones,
              }),
          );

          final decoded = json.decode(response.body);

          if(response.statusCode == 200){
            return {
              "success": decoded["Response"]["success"],
              "message": decoded["Response"]["message"]
            };
          }else{
            return{
              "success": false,
              "message": "Error en el servidor: ${response.statusCode}"
            };
          }
      }catch(e){
        return {
          "success": false,
          "message": "Error inesperado: $e",
        };
      }finally{
        _isloading = false;
        notifyListeners();
      }
    }
}





