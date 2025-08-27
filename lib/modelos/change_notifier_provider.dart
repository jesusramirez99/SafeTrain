import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// CLASE PARA SELECCIONAR LAS FILAS
class SelectionNotifier extends ChangeNotifier {
  ValueNotifier<int?> selectedRowNotifier = ValueNotifier<int?>(null);

  void updateSelectedRow(int? index) {
    selectedRowNotifier.value = index;
    notifyListeners();

  }
}

class SelectedRowModel extends ChangeNotifier {
  int? _selectedRowIndex;
  String? _selectedStatus;
  String? _selectedOffered;

  int? get selectedRowIndex => _selectedRowIndex;
  String? get selectedStatus => _selectedStatus;
  String? get selectedOffered => _selectedOffered;

  void setSelectedRow({
    required int index,
    required String status,
    required String offered,
  }) {
    _selectedRowIndex = index;
    _selectedStatus = status;
    _selectedOffered = offered;
    notifyListeners();
  }

  void clearSelection() {
    _selectedRowIndex = -1;
    _selectedStatus = '';
    _selectedOffered = '';
    notifyListeners();
  }

  bool get canValidate {
    if (_selectedRowIndex == null) return false;
    final status = _selectedStatus ?? '';
    final hasOffered = _selectedOffered != null && _selectedOffered!.isNotEmpty;

    if (hasOffered) {
      if (status.contains("Rechazado")) return true;
      if (status.isEmpty) return false;
      if (status.contains("Autorizado")) return false;
      return false;
    } else {
      return true;
    }
  }
}

// CLASE PARA OBTENER EL ID de un tren
class IdTren extends ChangeNotifier {
  int? _idTren;
  int? get idTren => _idTren;

  void setSelectedID(String id) {
    _idTren = int.tryParse(id.trim()) ??
        0; // Asegura que el valor sea un número válido
    notifyListeners();
  }
}

// CLASE PARA GESTIONAR LOS BOTONES DEL MENU LATERAL
class ButtonStateNotifier extends ChangeNotifier {
  Map<String, bool> buttonStates = {
    'indicador': true,
    'informacion': true,
    'validar': true,
    'cancelar': true,
    // Agrega otros botones aquí
  };

  bool isButtonEnabled(String buttonKey) {
    return buttonStates[buttonKey] ?? true;
  }

  void setButtonState(String buttonKey, bool isEnabled) {
    buttonStates[buttonKey] = isEnabled;
    notifyListeners();
  }
}

// CLASE PARA SELECCIONAR LOS CAMPOS ID TREN Y FECHA
class TrainSelectionProvider with ChangeNotifier {
  TextEditingController idTrainController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  void updateTrainSelection(String trainId, String trainDate) {
    idTrainController.text = trainId;
    fechaController.text = trainDate;
    notifyListeners();
  }
}

// CLASE PARA OBTENER LA FECHA Y HORA
class DateProvider with ChangeNotifier {
  String _currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String _currentTime = DateFormat('HH:mm').format(DateTime.now());

  String get currentDate => _currentDate;
  String get currentTime => _currentTime;

  DateProvider() {
    updateDateTime();
  }

  void updateDateTime() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      _currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
      _currentTime = DateFormat('HH:mm').format(DateTime.now());
      notifyListeners();
    });
  }
}

// CLASE PARA MANEJAR EL ESTADO DE AUTORIZADO DE UN TREN
class AutorizadoProvider extends ChangeNotifier {
  bool _isAutorizado = false;

  bool get isAutorizado => _isAutorizado;

  void setAutorizado(bool value) {
    if (_isAutorizado != value) {
      _isAutorizado = value;
      notifyListeners();
    }
  }
}
