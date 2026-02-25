import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/UpdateStationsUser_provider.dart';
import 'package:safe_train/modelos/region_division_estacion_provider.dart';
import 'package:safe_train/widgets/custom_dropdown_button.dart';

class ModalUpdatestationsuser extends StatefulWidget {
  final int userId;
  final List estaciones;
  final String username;
  final String nombre;

  const ModalUpdatestationsuser({
    Key? key,
    required this.userId,
    required this.estaciones,
    required this.username,
    required this.nombre,
  }) : super(key: key);

  @override
  State<ModalUpdatestationsuser> createState() =>
      _ModalUpdatestationsuserState();
}

class _ModalUpdatestationsuserState extends State<ModalUpdatestationsuser> {
  final ValueNotifier<List<Map<String, String>>> _addedEstacionesNotifier =
      ValueNotifier<List<Map<String, String>>>([]);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String _selectedRegion = 'Seleccione una Región';
  String _selectedDivision = 'Seleccione una División';
  String _selectedEstacion = 'Seleccione una Estación';

  TextEditingController? _autocompleteController;
  String? _errorEstacion;

  @override
  void initState() {
    super.initState();
    _autocompleteController = TextEditingController();
    _addedEstacionesNotifier.value = widget.estaciones.map<Map<String, String>>((e) {
      return {
        "Region": e['Region'] ?? "",
        "Estacion": e['Estacion'] ?? '',
      };
    }).toList();
  }

  @override
  void dispose() {
    _addedEstacionesNotifier.dispose();
    _autocompleteController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        width: 850.0,
        height: 540.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Provider.of<RegionDivisionEstacionProvider>(context, listen: false),
            ),
            ChangeNotifierProvider(
              create: (_) => UpdatestationsuserProvider(),
            ),
          ],
          child: StatefulBuilder(
            builder: (context, setState) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                    final provider =
                        Provider.of<RegionDivisionEstacionProvider>(context,
                            listen: false);
                    if (provider.regiones.isEmpty) {
                      await provider.fetchRegiones();
                    }
              });

              return Form(
                key: formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                'Editar Estaciones',
                                style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 20),

                            // Campos de Usuario y Nombre
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildField('Usuario:', campoUsername()),
                                      _buildField('Nombre:', campoNombre()),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 30),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Dropdown Región
                                      Consumer<RegionDivisionEstacionProvider>(
                                        builder: (context, provider, child) {
                                          final regionesList = [
                                            'Seleccione una Región',
                                            ...provider.regiones
                                          ];
                                          return _buildDropdownField(
                                            'Región:',
                                            regionesList,
                                            _selectedRegion,
                                            (newValue) async {
                                              setState(() {
                                                _selectedRegion = newValue!;
                                                _selectedDivision =
                                                    'Seleccione una División';
                                                _selectedEstacion =
                                                    'Seleccione una Estación';
                                                _autocompleteController?.clear();
                                              });
                                              if (_selectedRegion !=
                                                  'Seleccione una Región') {
                                                provider.clearDivisiones();
                                                provider.clearEstaciones();
                                                await provider.fetchDivisiones(
                                                    region: _selectedRegion);
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8.0),

                                      // Dropdown Divisiones
                                      if (_selectedRegion !=
                                          'Seleccione una Región')
                                        Consumer<RegionDivisionEstacionProvider>(
                                          builder: (context, provider, child) {
                                            final divisionesList = [
                                              'Seleccione una División',
                                              ...provider.divisiones
                                            ];
                                            return _buildDropdownField(
                                              'División:',
                                              divisionesList,
                                              _selectedDivision,
                                              (newValue) async {
                                                setState(() {
                                                  _selectedDivision = newValue!;
                                                  _selectedEstacion =
                                                      'Seleccione una Estación';
                                                  _autocompleteController?.clear();
                                                });
                                                if (_selectedDivision !=
                                                    'Seleccione una División') {
                                                  provider.clearEstaciones();
                                                  await provider.fetchEstaciones(
                                                      division:
                                                          _selectedDivision);
                                                }
                                              },
                                            );
                                          },
                                        ),

                                      const SizedBox(height: 10.0),

                                      // Autocomplete Estaciones
                                      if (_selectedDivision !=
                                          'Seleccione una División')
                                        Consumer<RegionDivisionEstacionProvider>(
                                          builder: (context, provider, child) {
                                            final estacionesList =
                                                provider.estaciones;
                                            return Autocomplete<String>(
                                              optionsBuilder:
                                                  (TextEditingValue
                                                      textEditingValue) {
                                                if (textEditingValue.text.isEmpty) {
                                                  return const Iterable<String>.empty();
                                                }
                                                return estacionesList.where(
                                                  (option) => option
                                                      .toLowerCase()
                                                      .contains(textEditingValue
                                                          .text
                                                          .toLowerCase()),
                                                );
                                              },
                                              fieldViewBuilder: (context,
                                                  textEditingController,
                                                  focusNode,
                                                  onFieldSubmitted) {
                                                _autocompleteController =
                                                    textEditingController;
                                                return TextField(
                                                  controller:
                                                      textEditingController,
                                                  focusNode: focusNode,
                                                  decoration: InputDecoration(
                                                    labelText: 'Estación',
                                                    hintText:
                                                        'Ingrese la estación',
                                                    border:
                                                        const OutlineInputBorder(),
                                                    errorText: _errorEstacion,
                                                  ),
                                                );
                                              },
                                              onSelected: (selection) {
                                                setState(() {
                                                  _selectedEstacion = selection;
                                                  _errorEstacion = null;
                                                });
                                              },
                                            );
                                          },
                                        ),

                                      const SizedBox(height: 13.0),

                                      // Botón agregar estación
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              final nuevaEstacion =
                                                  _autocompleteController
                                                          ?.text
                                                          .trim() ??
                                                      '';
                                              if (nuevaEstacion.isEmpty ||
                                                  _selectedEstacion ==
                                                      'Seleccione una Estación') {
                                                setState(() {
                                                  _errorEstacion =
                                                      'Seleccione una estación válida';
                                                });
                                                return;
                                              }

                                              if (_selectedRegion ==
                                                  'Seleccione una Región') {
                                                setState(() {
                                                  _errorEstacion =
                                                      'Seleccione una región primero';
                                                });
                                                return;
                                              }

                                              final nuevaEntrada = {
                                                "Region": _selectedRegion,
                                                "Estacion": nuevaEstacion,
                                              };

                                              final yaExiste = _addedEstacionesNotifier
                                                  .value
                                                  .any((element) =>
                                                      element["Region"] ==
                                                          _selectedRegion &&
                                                      element["Estacion"] ==
                                                          nuevaEstacion);

                                              if (yaExiste) {
                                                setState(() {
                                                  _errorEstacion =
                                                      'La estación ya está agregada para esta región';
                                                });
                                                return;
                                              }

                                              final newList =
                                                  List<Map<String, String>>.from(
                                                          _addedEstacionesNotifier
                                                              .value)
                                                    ..add(nuevaEntrada);
                                              _addedEstacionesNotifier.value =
                                                  newList;
                                              _autocompleteController?.clear();
                                              setState(() {
                                                _errorEstacion = null;
                                              });
                                            },
                                            child: _btnAddEstacion(),
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

                    // Mostrar estaciones agregadas
                    ValueListenableBuilder<List<Map<String, String>>>(
                      valueListenable: _addedEstacionesNotifier,
                      builder: (context, estaciones, _) {
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
                              label: Text(estacion['Estacion'] ?? ''),
                              backgroundColor: Colors.blue.shade100,
                              deleteIcon: Icon(Icons.close, color: Colors.red),
                              onDeleted: () {
                                final newList =
                                    List<Map<String, String>>.from(estaciones)
                                      ..remove(estacion);
                                _addedEstacionesNotifier.value = newList;
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const Divider(),
                    const SizedBox(height: 20.0),

                    // Botones
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
  }

  Widget _buildField(String label, Widget field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(child: field),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items,
      String selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600)),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: FormField<String>(
              initialValue: selectedValue,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: Text(state.errorText ?? '',
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0)),
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

  Widget campoUsername() {
    return TextFormField(
      initialValue: widget.username,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.account_box_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
      ),
    );
  }

  Widget campoNombre() {
    return TextFormField(
      initialValue: widget.nombre,
      readOnly: true,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.accessibility_new),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0)),
      ),
    );
  }

  Widget _btnAddEstacion() {
    return Icon(Icons.add, size: 24.0, color: Colors.green[300]);
  }

  Widget _btnSalir(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(),
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(Colors.grey.shade300),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),

          
          ),

      child: Row(
        children: [
          Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18.0),
          const SizedBox(width: 5.0),
          Text('Salir',
              style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _btnRegistrar(BuildContext context) {
  return ElevatedButton(
    onPressed: () async {
      final estacionesAEnviar = _addedEstacionesNotifier.value;
      final userId = widget.userId;
      final provider = Provider.of<UpdatestationsuserProvider>(context, listen: false);
      final result = await provider.updateEstacionesUser(userId, estacionesAEnviar);
      if (result["success"] == true) {
        Navigator.of(context).pop(true); // cerramos el modal
      }
    },
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade300),
    ),
    child: Row(
      children: const [
        Icon(Icons.app_registration, color: Colors.green, size: 18.0),
        SizedBox(width: 5.0),
        Text('Registrar'),
      ],
    ),
  );
}
}