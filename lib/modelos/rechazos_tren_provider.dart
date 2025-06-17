import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RechazosProvider extends ChangeNotifier {
  List<String> _trenesOfrecidos = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;

  List<String> get trenesOfrecidos => _trenesOfrecidos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void startAutoRefresh(BuildContext context, String user) {
    _timer?.cancel();
    fetchRechazos(context, user);

    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      fetchRechazos(context, user);
    });
  }

  // FUNCION PARA MOSTRAR LOS TRENES RECHAZADOS A CIERTOS USUARIOS POR REGION
  Future<void> fetchRechazos(BuildContext context, String user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url =
          'http://10.10.76.150/TrenSeguroDev/api/getRechazosUsuario?userId=$user';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('DataTren') &&
            jsonResponse['DataTren'] is Map<String, dynamic> &&
            jsonResponse['DataTren'].containsKey('wrapper') &&
            jsonResponse['DataTren']['wrapper'] is List) {
          final List<String>? trenes =
              (jsonResponse['DataTren']['wrapper'] as List<dynamic>?)
                  ?.map((e) => e.toString()) // Convertir a String por seguridad
                  .toList();

          _trenesOfrecidos = trenes ?? [];
        } else {
          _trenesOfrecidos = [];
          _errorMessage = 'No hay trenes rechazados disponibles';
        }
      } else {
        _errorMessage = 'Error en la API: Código ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void refreshRechazos(BuildContext context, String user) {
    fetchRechazos(context, user);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
