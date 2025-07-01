import 'package:flutter/material.dart';

// PROVIDER PARA OBTENER EL USER
class UserProvider extends ChangeNotifier {
  String? _userName;

  String? get userName => _userName;

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }
}

class RoleProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  String? get role => _userData?['ROLE']; // Accede a la propiedad 'ROLE'

  void setUserData(Map<String, dynamic> data) {
    _userData = data;
    notifyListeners();
  }
}



// PROVIDER PARA OBTENER EL FFCC
class FfccProvider extends ChangeNotifier {
  String _selectedItem = 'FFCC';

  String get selectedItem => _selectedItem;

  void setSelectedItem(String newValue) {
    _selectedItem = newValue;
    notifyListeners();
  }
}

// PROVIDER PARA OBTENER LA REGION
class RegionProvider extends ChangeNotifier {
  String? _region;

  String? get region => _region;

  void setRegion(String newRegion) {
    _region = newRegion;
    notifyListeners();
  }
}

// clase para obtener el tren
class TrainModel with ChangeNotifier {
  String? _selectedTrain;

  String? get selectedTrain => _selectedTrain;

  void setSelectedTrain(String trenId) {
    _selectedTrain = trenId;
    notifyListeners();
  }

  void clearData() {
    _selectedTrain = null; // Ahora sí puedes asignar null
    notifyListeners();
  }
}

class MotivosRechazo with ChangeNotifier {
  String? selectedTrain;
  String? motivoRechazo;
  String? observaciones;

  void setSelectedTrain(String trainId, String motivo, String obs) {
    selectedTrain = trainId;
    motivoRechazo = motivo;
    observaciones = obs;
    notifyListeners();
  }

  void clearData() {
    selectedTrain = null; // Ahora sí puedes asignar null
    notifyListeners();
  }
}

class MotRechazoObs with ChangeNotifier {
  int idTrain = 0; // Inicializa con 0 para evitar errores
  String? motivoRechazo;
  String? observaciones;

  void setSelectedTrain(int id, String motivo, String obs) {
    idTrain = id;
    motivoRechazo = motivo;
    observaciones = obs;
    notifyListeners();
  }

  void clearData() {
    idTrain = 0; // Ahora sí se limpia correctamente
    motivoRechazo = null;
    observaciones = null;
    notifyListeners();
  }
}
