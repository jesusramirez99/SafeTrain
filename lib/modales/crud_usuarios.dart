import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/region_division_estacion_provider.dart';
import 'package:safe_train/widgets/custom_dropdown_button.dart';

class Usuarios extends StatefulWidget {
  const Usuarios({
    super.key,
  });

  @override
  State<Usuarios> createState() => UsuariosState();
}

class UsuariosState extends State<Usuarios> {
  final ValueNotifier<List<String>> _addedEstacionesNotifier =
      ValueNotifier<List<String>>([]);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  //final TextEditingController _stationController = TextEditingController();
  final FocusNode _stationFocusNode = FocusNode();
  TextEditingController? _autocompleteController;
  String? _errorEstacion;

  String _selectedRol = 'Seleccione un Rol';
  String _selectedRegion = 'Seleccione una Región';
  String _selectedDivision = 'Seleccione una División';
  String _selectedEstacion = 'Seleccione una Estación';

  @override
  void initState() {
    super.initState();
    _autocompleteController = TextEditingController();
  }

  @override
  void dispose() {
    _addedEstacionesNotifier.dispose();
    _autocompleteController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  // mdl usuarios
  Future<void> mdlUsuarios(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider.value(
          // Se pasa la instancia existente del provider para asegurar que el contenido tenga acceso
          value: Provider.of<RegionDivisionEstacionProvider>(context,
              listen: false),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              width: 850.0,
              height: 540.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    final provider =
                        Provider.of<RegionDivisionEstacionProvider>(context,
                            listen: false);

                    if (provider.roles.isEmpty) {
                      await provider.fetchRoles();
                    }

                    if (provider.regiones.isEmpty) {
                      await provider.fetchRegiones();
                    }
                  });

                  return Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10.0),
                                Center(
                                  child: Text(
                                    'Usuarios',
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                const SizedBox(height: 20.0),

                                // División en dos columnas
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildField(
                                              'Usuario:', campoUsername()),
                                          _buildField('Nombre:', campoNombre()),
                                          _buildField('Email @:', campoEmail()),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 30.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // dropdown para mostrar los roles
                                          Consumer<
                                              RegionDivisionEstacionProvider>(
                                            builder:
                                                (context, provider, child) {
                                              final rolList = [
                                                'Seleccione un Rol',
                                                ...provider.roles,
                                              ];
                                              return _buildDropdownField(
                                                'Rol:',
                                                rolList,
                                                _selectedRol,
                                                (newValue) async {
                                                  setState(() {
                                                    // Reinicia el rol
                                                    _selectedRol = newValue!;
                                                    // Reinicia la región, división y estación a sus valores por defecto
                                                    _selectedRegion =
                                                        'Seleccione una Región';
                                                    _selectedDivision =
                                                        'Seleccione una División';
                                                    _selectedEstacion =
                                                        'Seleccione una Estación';
                                                    // Limpia el TextField de Estaciones (si aplica)
                                                    _autocompleteController
                                                        ?.clear();
                                                  });

                                                  if (_selectedRol !=
                                                      'Seleccione un Rol') {
                                                    // Limpiamos las listas de divisiones y estaciones del provider
                                                    Provider.of<RegionDivisionEstacionProvider>(
                                                            context,
                                                            listen: false)
                                                        .clearRegiones();
                                                    Provider.of<RegionDivisionEstacionProvider>(
                                                            context,
                                                            listen: false)
                                                        .clearDivisiones();
                                                    Provider.of<RegionDivisionEstacionProvider>(
                                                            context,
                                                            listen: false)
                                                        .clearEstaciones();

                                                    // Llamar fetchDivisiones o fetchRegiones según lo requieras
                                                    await Provider.of<
                                                                RegionDivisionEstacionProvider>(
                                                            context,
                                                            listen: false)
                                                        .fetchRegiones();
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 8.0),

                                          // Dropdown para motrar las regiones
                                          if (_selectedRol !=
                                              'Seleccione un Rol')
                                            // Dropdown de Regiones
                                            Consumer<
                                                RegionDivisionEstacionProvider>(
                                              builder:
                                                  (context, provider, child) {
                                                final regionesList = [
                                                  'Seleccione una Región',
                                                  ...provider.regiones,
                                                ];
                                                return _buildDropdownField(
                                                  'Región:',
                                                  regionesList,
                                                  _selectedRegion,
                                                  (newValue) async {
                                                    setState(() {
                                                      _selectedRegion =
                                                          newValue!;
                                                      _selectedDivision =
                                                          'Seleccione una División';
                                                      _selectedEstacion =
                                                          'Seleccione una Estación';
                                                      _autocompleteController
                                                          ?.clear();
                                                      _autocompleteController =
                                                          null; // Reiniciamos para que se cree uno nuevo
                                                      // También, opcionalmente, vacía la lista de estaciones agregadas:
                                                    });
                                                    if (_selectedRegion !=
                                                        'Seleccione una Región') {
                                                      Provider.of<RegionDivisionEstacionProvider>(
                                                              context,
                                                              listen: false)
                                                          .clearDivisiones();
                                                      Provider.of<RegionDivisionEstacionProvider>(
                                                              context,
                                                              listen: false)
                                                          .clearEstaciones();

                                                      await Provider.of<
                                                                  RegionDivisionEstacionProvider>(
                                                              context,
                                                              listen: false)
                                                          .fetchDivisiones(
                                                              region:
                                                                  _selectedRegion);
                                                    }
                                                  },
                                                );
                                              },
                                            ),

                                          const SizedBox(height: 8.0),

                                          // Dropdown para mostrar las  Divisiones
                                          if (_selectedRegion !=
                                              'Seleccione una Región')
                                            Consumer<
                                                RegionDivisionEstacionProvider>(
                                              builder:
                                                  (context, provider, child) {
                                                final List<String> divisiones =
                                                    provider.divisiones;
                                                final divisionesList = [
                                                  'Seleccione una División',
                                                  ...divisiones
                                                ];
                                                return _buildDropdownField(
                                                  'Divisiones:',
                                                  divisionesList,
                                                  _selectedDivision,
                                                  (newValue) async {
                                                    setState(() {
                                                      _selectedDivision =
                                                          newValue!;
                                                      _selectedEstacion =
                                                          'Seleccione una Estación';
                                                      _autocompleteController
                                                          ?.clear();
                                                    });
                                                    // Solicita el foco para que el cursor vuelva al campo de estaciones.
                                                    _stationFocusNode
                                                        .requestFocus();

                                                    if (_selectedDivision !=
                                                        'Seleccione una División') {
                                                      // Limpia la lista de estaciones y realiza la consulta para la nueva división.
                                                      Provider.of<RegionDivisionEstacionProvider>(
                                                              context,
                                                              listen: false)
                                                          .clearEstaciones();
                                                      await Provider.of<
                                                                  RegionDivisionEstacionProvider>(
                                                              context,
                                                              listen: false)
                                                          .fetchEstaciones(
                                                              division:
                                                                  _selectedDivision);
                                                    }
                                                  },
                                                );
                                              },
                                            ),

                                          const SizedBox(height: 10.0),

                                          // Autocomplete para Estaciones:
                                          if (_selectedDivision !=
                                              'Seleccione una División')
                                            Consumer<
                                                RegionDivisionEstacionProvider>(
                                              builder: (context,
                                                  estacionesProvider, child) {
                                                final List<String>
                                                    estacionesList =
                                                    estacionesProvider
                                                        .estaciones;
                                                return Autocomplete<String>(
                                                  optionsBuilder:
                                                      (TextEditingValue
                                                          textEditingValue) {
                                                    if (textEditingValue
                                                        .text.isEmpty) {
                                                      return const Iterable<
                                                          String>.empty();
                                                    }
                                                    // Usa la lista definida en lugar de "provider.estaciones"
                                                    return estacionesList.where(
                                                      (option) => option
                                                          .toLowerCase()
                                                          .contains(
                                                              textEditingValue
                                                                  .text
                                                                  .toLowerCase()),
                                                    );
                                                  },
                                                  fieldViewBuilder: (BuildContext
                                                          context,
                                                      TextEditingController
                                                          textEditingController,
                                                      FocusNode focusNode,
                                                      VoidCallback
                                                          onFieldSubmitted) {
                                                    // Asignamos o reemplazamos el controlador para cada reconstrucción
                                                    _autocompleteController =
                                                        textEditingController;
                                                    return TextField(
                                                      controller:
                                                          textEditingController,
                                                      focusNode: focusNode,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText: 'Estación',
                                                        hintText:
                                                            'Ingrese la estación',
                                                        border:
                                                            const OutlineInputBorder(),
                                                        errorText:
                                                            _errorEstacion,
                                                      ),
                                                    );
                                                  },
                                                  onSelected:
                                                      (String selection) {
                                                    setState(() {
                                                      _selectedEstacion =
                                                          selection;
                                                      _errorEstacion = null;
                                                    });
                                                  },
                                                );
                                              },
                                            ),

                                          const SizedBox(height: 13.0),

                                          // Botón para agregar estaciones:
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  final String nuevaEstacion =
                                                      _autocompleteController!
                                                          .text
                                                          .trim();
                                                  if (nuevaEstacion
                                                          .isNotEmpty &&
                                                      nuevaEstacion !=
                                                          'Seleccione una Estación') {
                                                    // Verifica si ya existe
                                                    if (_addedEstacionesNotifier
                                                        .value
                                                        .contains(
                                                            nuevaEstacion)) {
                                                      setState(() {
                                                        _errorEstacion =
                                                            'La estación ya está agregada';
                                                      });
                                                    } else {
                                                      final newList = List<
                                                              String>.from(
                                                          _addedEstacionesNotifier
                                                              .value)
                                                        ..add(nuevaEstacion);
                                                      _addedEstacionesNotifier
                                                          .value = newList;
                                                      _autocompleteController
                                                          ?.clear();
                                                      setState(() {
                                                        _errorEstacion = null;
                                                        _selectedEstacion =
                                                            nuevaEstacion;
                                                      });
                                                      print(
                                                          "Estaciones después de agregar: ${_addedEstacionesNotifier.value.length}");
                                                    }
                                                  }
                                                },
                                                child:
                                                    _btnAddEstacion(), // Tu método o widget que define el contenido del botón
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ValueListenableBuilder<List<String>>(
                          valueListenable: _addedEstacionesNotifier,
                          builder: (context, estaciones, _) {
                            print(
                                "ValueListenableBuilder - estaciones: ${estaciones.length}");
                            if (estaciones.isEmpty) {
                              return const Text(
                                "No hay estaciones agregadas",
                                style: TextStyle(color: Colors.red),
                              );
                            }
                            return Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: estaciones.map((estacion) {
                                return Chip(
                                  label: Text(estacion),
                                  backgroundColor: Colors.blue.shade100,
                                  deleteIcon: Icon(Icons.close, color: Colors.red),
                                  onDeleted: () {
                                    setState(() {
                                      estaciones.remove(estacion);
                                    });
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const Divider(),
                        const SizedBox(height: 20.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _btnSalir(context),
                            _btnRegistrar(context),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

// Función para estructurar los campos con etiquetas alineadas
  Widget _buildField(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Espaciado uniforme
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 120.0, // Ajustamos el ancho de la etiqueta
            height: 40.0,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Flexible(
            child: SizedBox(
              width: 320.0, // Tamaño mínimo para los cuadros de texto
              child: field,
            ),
          ),
        ],
      ),
    );
  }

// Función para estructurar los dropdowns con más tamaño horizontal
  Widget _buildDropdownField(
    String label,
    List<String> items, // Ahora se recibe la lista
    String selectedValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Reduce el ancho de la etiqueta si no es necesario que sea tan ancho
          SizedBox(
            width: 100.0, // Ajusta este valor según convenga
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          // Puede usarse un SizedBox para dar un pequeño espacio entre el label y el dropdown
          const SizedBox(width: 6.0),
          SizedBox(
            width: 250.0, // Ancho fijo para el dropdown
            child: FormField<String>(
              initialValue: selectedValue,
              validator: (value) {
                if (value == null || value == items.first) {
                  return 'Selecciona una opción válida';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownButton(
                      key: ValueKey('${items.toString()}_${selectedValue}'),
                      label: '',
                      items: items,
                      selectedValue: selectedValue,
                      onChanged: (value) {
                        onChanged(value);
                        state.didChange(value);
                      },
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          state.errorText!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // btn para agregar las estaciones
  Widget _btnAddEstacion() {
    return Icon(
      Icons.add,
      size: 24.0,
      color: Colors.green[300],
    );
  }

  Future<void> _submit() async {
    if (formKey.currentState!.validate()) {
      print('submit');
    }
  }

  // CAMPO STCC
  Widget campoUsername() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextFormField(
        controller: _userNameController,
        onChanged: (text) {
          _userNameController.text = text.toUpperCase();
          _userNameController.selection = TextSelection.fromPosition(
              TextPosition(offset: _userNameController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar un Username';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.account_box_rounded),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13.0,
          ), // Ajustar el espacio vertical dentro del TextFormField
          isDense: true,
        ),
      ),
    );
  }

  // CAMPO DESCRIPCION
  Widget campoNombre() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 25.0),
      child: TextFormField(
        controller: _nameController,
        onChanged: (text) {
          _nameController.text = text.toUpperCase();
          _nameController.selection = TextSelection.fromPosition(
              TextPosition(offset: _nameController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar su nombre y apellido';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.accessibility_new),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12),
          isDense: true,
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  // CAMPO CLASE
  Widget campoEmail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7.0),
      child: TextFormField(
        controller: emailController,
        onChanged: (text) {},
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'favor de ingresar su email';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'example@ferromex.mx',
          prefixIcon: const Icon(Icons.alternate_email_rounded),
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 13.0,
          ), // Ajustar el espacio vertical dentro del TextFormField
          isDense: true,
        ),
      ),
    );
  }

  // BOTON REGISTRAR
  Widget _btnRegistrar(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          // Verificar que haya al menos una estación en el ValueNotifier
          if (_addedEstacionesNotifier.value.isEmpty) {
            // Mostrar mensaje de error si no hay estaciones agregadas
            await showFlushbar(
              context,
              "Favor de agregar al menos una estación",
              Colors.red.shade400,
              const Duration(seconds: 4),
            );
            return;
          }

          await _submit();

          await showFlushbar(
            context,
            "Registro exitoso",
            Colors.green.shade400,
            const Duration(seconds: 4),
          );
          Navigator.of(context).pop();
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.app_registration, color: Colors.green, size: 18.0),
          const SizedBox(width: 5.0),
          Text('Registrar',
              style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // BOTON CANCELAR
  Widget _btnSalir(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        Navigator.of(context).pop();
        _userNameController.clear();
        _nameController.clear();
        emailController.clear();
        passController.clear();
        //rol
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            Colors.grey.shade300), // Color de fondo del botón
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18.0),
          const SizedBox(width: 5.0),
          Text(
            'Salir',
            style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // Mensaje de flushbar
  Future<void> showFlushbar(
      BuildContext context, String message, Color color, Duration duration) {
    return Flushbar(
      duration: duration,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      backgroundColor: color,
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }
}
