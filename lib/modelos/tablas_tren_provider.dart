import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/estaciones_provider.dart';
import 'package:safe_train/modelos/historico_validacion_trenes_provider.dart';

class TablesTrainsProvider with ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _dataTrain = [];
  List<Map<String, dynamic>> _infoTrain = [];
  String? _selectedID;
  int id = 0;

  String? get selectedID => _selectedID;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get dataTrain => _dataTrain;

  int _rowsPerPage = 10;
  List<Map<String, dynamic>> get infoTrain => _infoTrain;
  int get rowsPerPage => _rowsPerPage;

  // variable para motivos de rechazo
  List<String> _motivosRechazo = [];
  String _observaciones = "";

  List<String> get motivosRechazo => _motivosRechazo;
  String get observaciones => _observaciones;

  void setSelectedID(String id) {
    _selectedID = id;
    notifyListeners();
  }

  void clearData() {
    _dataTrain = [];
    notifyListeners();
  }

  void actualizarDatos(HistorialValidacionesProvider historialProvider) {
    _motivosRechazo = historialProvider.motivosRechazo;
    _observaciones = historialProvider.observaciones;
    notifyListeners();
  }

  // FUNCION PARA MOSTRAR LOS DATOS DEL TREN
  Future<void> tableDataTrain(BuildContext context, String trenYFecha,
      final ffcc, String estacion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getInfoTren?idTren=$trenYFecha&ffcc=$ffcc&estacion=$estacion');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['Consist'] != null &&
            jsonData['Consist']['Result'] != null &&
            jsonData['Consist']['Result']['wrapper'] != null &&
            jsonData['Consist']['Result']['wrapper'] is Map) {
          final Map<String, dynamic> _wrapper =
              jsonData['Consist']['Result']['wrapper'];

          final estacionActual = _wrapper['estacion_actual'];
          print('estacion actual: $estacionActual');

          final estacionProvider =
              Provider.of<EstacionesProvider>(context, listen: false);
          final estacionSeleccionada = estacionProvider.selectedEstacion;
          print('estacion seleccionada: $estacionSeleccionada');

          if (estacionSeleccionada == estacionActual) {
            _wrapper['ID'] = _wrapper['ID'] ?? 'No disponible';
            _wrapper['destino'] = _wrapper['destino'] ?? 'No disponible';
            _wrapper['cargados'] = _wrapper['cargados'] ?? 0;
            _wrapper['carros'] = _wrapper['carros'] ?? 0;
            _wrapper['vacios'] = _wrapper['vacios'] ?? 0;

            _dataTrain.add(_wrapper);
            notifyListeners();
          } else {
            _wrapper.remove('estacion_actual');
            _wrapper.remove('validado');
            _wrapper.remove('fecha_validado');
            print('Estación seleccionada no coincide. Atributos descartados');
            print(_wrapper);

            _dataTrain = [_wrapper];
            notifyListeners();
          }
        } else {
          _showFlushbar(context,
              'El tren "$trenYFecha" no fue encontrado, favor de verificar.');
          _isLoading = false;
          notifyListeners();
        }
      } else {
        _showFlushbar(context, 'Error en la solicitud: ${response.statusCode}');
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _showFlushbar(context, 'Ocurrió un error: $e');
      print('error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FUNCION PARA REFRESCAR LA TABLA DESPUES DE VALIDAR EL TREN
  Future<void> refreshTableDataTrain(
      BuildContext context, String train, String estacion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getDataTren?idTren=$train&estacion=$estacion');
      final response = await http.get(
        url,
        headers: {
          "Cache-Control": "no-cache",
          "Pragma": "no-cache",
          "Expires": "0"
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['DataTren'] != null &&
            jsonData['DataTren']['wrapper'] != null &&
            jsonData['DataTren']['wrapper'] is Map) {
          final Map<String, dynamic> wrapperData =
              jsonData['DataTren']['wrapper'];

          // Guardar el ID
          final ID = wrapperData['ID']?.toString();
          setSelectedID(ID ?? '');
          print('ID guardado en el provider: $ID');

          // Normalizar datos
          wrapperData['ID'] = wrapperData['ID'] ?? 'No disponible';
          wrapperData['destino'] = wrapperData['destino'] ?? 'No disponible';
          wrapperData['cargados'] = wrapperData['cargados'] ?? 0;
          wrapperData['carros'] = wrapperData['carros'] ?? 0;
          wrapperData['vacios'] = wrapperData['vacios'] ?? 0;

          // Limpiar y actualizar lista
          _dataTrain = [];
          notifyListeners();
          _dataTrain.add(wrapperData);

          notifyListeners();
        } else {
          _showFlushbar(
              context, 'El tren "$train" no fue encontrado, favor de revisar.');
          print('Datos no encontrados para el tren "$train"');
        }
      } else {
        _showFlushbar(context, 'Error en la solicitud: ${response.statusCode}');
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showFlushbar(context, 'Ocurrió un error: $e');
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FUNCION PARA MOSTRAR LOS TRENES RECHAZADOS
  Future<void> showTrenesRechazados(BuildContext context, String train) async {
    _isLoading = true;
    notifyListeners(); // Notificar inicio de carga

    try {
      final url = Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getInfoTrenRechazadoCCO?idTren=$train');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['DataTren'] != null &&
            jsonData['DataTren']['wrapper'] != null &&
            jsonData['DataTren']['wrapper'] is Map) {
          final Map<String, dynamic> wrapperData =
              jsonData['DataTren']['wrapper'];

          // Obtener ID y validar
          final ID = wrapperData['ID']?.toString();
          setSelectedID(ID ?? '');
          print('ID guardado en el provider: $ID');

          // Normalizar datos
          wrapperData['ID'] = wrapperData['ID'] ?? 'No disponible';
          wrapperData['destino'] = wrapperData['destino'] ?? 'No disponible';
          wrapperData['cargados'] = wrapperData['cargados'] ?? 0;
          wrapperData['carros'] = wrapperData['carros'] ?? 0;
          wrapperData['vacios'] = wrapperData['vacios'] ?? 0;

          // Actualizar lista
          _dataTrain.clear(); // Limpiar lista antes de agregar datos
          _dataTrain.add(wrapperData); // Agregar nuevo registro

          print('Datos añadidos a la tabla: $_dataTrain');
          notifyListeners(); // Notificar que la lista cambió
        } else {
          _showFlushbar(
              context, 'El tren "$train" no fue encontrado, favor de revisar.');
          print('Datos no encontrados para el tren "$train"');
        }
      } else {
        _showFlushbar(context, 'Error en la solicitud: ${response.statusCode}');
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showFlushbar(context, 'Ocurrió un error: $e');
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notificar fin de carga
    }
  }

  // FUNCION PARA MOSTRAR MOTIVOS Y OBSERVACIONES DE RECHAZO DE TRENES POR CCO
  Future<String> fetchRechazoInfo(String idTren) async {
    _isLoading = true;

    // Asegurar que la notificación de cambio de estado se ejecute después del build
    Future.delayed(Duration.zero, () {
      notifyListeners();
    });

    final url = Uri.parse(
        'http://10.10.76.150/TrenSeguroDev/api/getInfoTrenRechazadoCCO?idTren=$idTren');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final wrapper = data['DataTren']['wrapper'];

        _motivosRechazo = (wrapper['motivos_rechazo'] as List)
            .map((item) => item['motivo'].toString())
            .toList();

        _observaciones = wrapper['observaciones'] ?? "Sin observaciones";

        return "Motivos: \n${_motivosRechazo.join("\n")}\n\nObservaciones:\n$_observaciones";
      } else {
        return "Error al obtener datos";
      }
    } catch (e) {
      return "Error de conexión";
    } finally {
      // Notificar después del build
      Future.delayed(Duration.zero, () {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  // FUNCION PARA MOSTRAR TRENES RECHAZADOS
  Future<void> mostrarTrenes(
      BuildContext context, String train, String estacion) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getDataTren?idTren=$train&estacion=$estacion');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['DataTren'] != null &&
            jsonData['DataTren']['wrapper'] != null &&
            jsonData['DataTren']['wrapper'] is Map) {
          final Map<String, dynamic> wrapperData =
              jsonData['DataTren']['wrapper'];

          // Obtener ID y validar
          final ID = wrapperData['ID']?.toString();
          setSelectedID(ID ?? '');
          print('ID guardado en el provider: $ID');

          // Normalizar datos
          wrapperData['ID'] = wrapperData['ID'] ?? 'No disponible';
          wrapperData['destino'] = wrapperData['destino'] ?? 'No disponible';
          wrapperData['cargados'] = wrapperData['cargados'] ?? 0;
          wrapperData['carros'] = wrapperData['carros'] ?? 0;
          wrapperData['vacios'] = wrapperData['vacios'] ?? 0;

          // Actualizar lista
          _dataTrain.clear(); // Limpiar lista antes de agregar datos
          _dataTrain.add(wrapperData); // Agregar nuevo registro

          print('Datos añadidos a la tabla: $_dataTrain');
          notifyListeners(); // Notificar que la lista cambió
        } else {
          _showFlushbar(
              context, 'El tren "$train" no fue encontrado, favor de revisar.');
          print('Datos no encontrados para el tren "$train"');
        }
      } else {
        _showFlushbar(context, 'Error en la solicitud: ${response.statusCode}');
        print('Error en la solicitud: ${response.statusCode}');
      }
    } catch (e) {
      _showFlushbar(context, 'Ocurrió un error: $e');
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notificar fin de carga
    }
  }

  // FUNCION PARA VER EL CONSIST DEL TREN
  Future<void> consistTren(
      BuildContext context, String train, String estacion) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(
          'http://10.10.76.150/TrenSeguroDev/api/getConsist?idTren=$train&estacion=$estacion'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        _infoTrain =
            List<Map<String, dynamic>>.from(jsonData['Consist']['wrapper']);
        _rowsPerPage = _infoTrain.length; // Establece filas por página
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a los widgets que el estado ha cambiado
    }
  }

  void _showFlushbar(BuildContext context, String message) {
    Flushbar(
      duration: const Duration(seconds: 6),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }
}
