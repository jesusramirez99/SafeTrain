import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/AddUser_provider.dart';
import 'package:safe_train/modelos/region_division_estacion_provider.dart';
import 'package:safe_train/widgets/custom_dropdown_button.dart';

class MdlUsuarios extends StatefulWidget {
  const MdlUsuarios({super.key});

  @override
  State<MdlUsuarios> createState() => _MdlUsuariosState();
}

class _MdlUsuariosState extends State<MdlUsuarios> {
  final ValueNotifier<List<Map<String, String>>> _addedEstacionesNotifier = ValueNotifier<List<Map<String, String>>>([]);
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final FocusNode _stationFocusNode = FocusNode();
  String regionSelected = '';
  String _selectedRol = 'Seleccione un Rol';
  String _selectedRegion = 'Seleccione una Región';
  String _selectedDivision = 'Seleccione una División';
  String _selectedEstacion = 'Seleccione una Estación';
  TextEditingController? _autocompleteController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _errorEstacion;
  final bool _isloading = false;
  int selectedRoleId = 0;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<RegionDivisionEstacionProvider>(context, listen: false);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Form(
            key: formKey,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              width: 850.0,
              height: 540.0,
              child: Column(
                children: <Widget>[
                  Expanded(
                    
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height:  10),
                          Center(
                            child: Text('Usuarios', style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 20),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildField('Usuario:', campoUsername()),
                                    _buildField('Nombre:', campoNombre()),
                                    _buildField('Email @:', campoEmail()),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer<RegionDivisionEstacionProvider>(builder: (context, provider, child) {
                                      final rolList = ['Seleccione un Rol', ...provider.roles.map((r) =>r['rol'] as String),];
                                      return _buildDropdownField(
                                        'Rol:', 
                                        rolList, 
                                        _selectedRol, 
                                        (newValue) async {
                                          setState(() {
                                            _selectedRol = newValue!;
                                            _selectedRegion = 'Seleccione una Región';
                                            _selectedDivision = 'Seleccione una División';
                                            _selectedEstacion = 'Seleccione una Estación';
                                            _autocompleteController?.clear();
                                          });
                                          if(_selectedRol != 'Seleccione un Rol'){
                                              Provider.of<RegionDivisionEstacionProvider>(context,listen: false).clearRegiones();
                                              Provider.of<RegionDivisionEstacionProvider>(context,listen: false).clearDivisiones();
                                              Provider.of<RegionDivisionEstacionProvider>(context,listen: false).clearEstaciones();    
                                              final selectedRole = provider.roles.firstWhere((r) => r['rol'] == _selectedRol);
                                              selectedRoleId = selectedRole['id'];
                                              // Llamar fetchDivisiones o fetchRegiones según lo requieras
                                              await Provider.of<RegionDivisionEstacionProvider>(context,listen: false).fetchRegiones();
                                          } 
                                        },
                                      );
                                    }),

                                    const SizedBox(height: 8.0),
                                    if(_selectedRol != 'Seleccione un Rol')
                                    Consumer<RegionDivisionEstacionProvider>(builder: (context, provider, child) {
                                      final regionesList = ['Seleccione una Región', ...provider.regiones];
                                      return _buildDropdownField(
                                        'Región:', 
                                        regionesList, 
                                        _selectedRegion, 
                                        (newValue) async {
                                          setState(() {
                                            regionSelected = _selectedRegion = newValue!;
                                            _selectedDivision ='Seleccione una División';
                                            _selectedEstacion ='Seleccione una Estación';
                                            _autocompleteController?.clear();
                                            _autocompleteController =null; // Reiniciamos para que se cree uno nuevo
                                            // También, opcionalmente, vacía la lista de estaciones agregadas:
                                          });

                                          if (_selectedRegion !='Seleccione una Región') {
                                            Provider.of<RegionDivisionEstacionProvider>(context,listen: false).clearDivisiones();
                                            Provider.of<RegionDivisionEstacionProvider>(context,listen: false).clearEstaciones();
                                            await Provider.of<RegionDivisionEstacionProvider>(context,listen: false).fetchDivisiones(region: _selectedRegion);
                                          }
                                        }
                                      );
                                    }),

                                    const SizedBox(height: 8.0),
                                    if(_selectedRegion != 'Seleccione una Región')
                                    Consumer<RegionDivisionEstacionProvider>(builder: (context, provider, child) {
                                      final List<String> divisiones = provider.divisiones;
                                      final divisionesList = ['Seleccione una División', ...divisiones];
                                      return _buildDropdownField(
                                        'Divisiones:', 
                                        divisionesList, 
                                        _selectedDivision, 
                                        (newValue) async {
                                          setState(() {
                                            _selectedDivision = newValue!;
                                            _selectedEstacion ='Seleccione una Estación';
                                            _autocompleteController?.clear();
                                          });
                                          _stationFocusNode.requestFocus();
                                          if (_selectedDivision !='Seleccione una División') {
                                            // Limpia la lista de estaciones y realiza la consulta para la nueva división.
                                            Provider.of<RegionDivisionEstacionProvider>(context,listen: false).clearEstaciones();
                                            await Provider.of<RegionDivisionEstacionProvider>(context,listen: false).fetchEstaciones(division:_selectedDivision);
                                          }
                                        }
                                      );
                                    }),

                                    const SizedBox(height:  10.0),
                                    if(_selectedDivision != 'Seleccione una División')
                                    Consumer<RegionDivisionEstacionProvider>(builder: (context, estacionesProvider, child) {
                                      final List<String> estacionesList = estacionesProvider.estaciones;
                                      return Autocomplete<String>(
                                        optionsBuilder: (TextEditingValue textEditingValue){
                                          if(textEditingValue.text.isEmpty){
                                            return const Iterable<String>.empty();
                                          }
                                          return estacionesList.where(
                                            (option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()),
                                          );
                                        },
                                        fieldViewBuilder: ( BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                          _autocompleteController = textEditingController;
                                          return TextField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            decoration: InputDecoration(
                                              labelText: 'Estación',
                                              hintText: 'Ingrese la estación',
                                              border:  const OutlineInputBorder(),
                                              errorText: _errorEstacion,
                                            ),
                                          );
                                        },
                                        onSelected: (String selection) {
                                          setState(() {
                                            _selectedEstacion = selection;
                                            _errorEstacion = null;
                                          });
                                        },
                                        
                                      );
                                      
                                    }),
                                    const SizedBox(height:  13.0),
                                    if(_selectedDivision != 'Seleccione una División')
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            final String nuevaEstacion = _autocompleteController?.text.trim() ?? '';
                                            if (nuevaEstacion.isEmpty || nuevaEstacion == 'Seleccione una Estación') {
                                              // Verifica si ya existe
                                              setState(() {
                                                _errorEstacion = 'Seleccione una estacion valida';
                                              });
                                              return;
                                            }

                                            if (_selectedRegion == 'Seleccione una Región') {
                                              setState(() {
                                                _errorEstacion = 'Seleccione una región primero';
                                              });
                                              return;
                                            }

                                            final nuevaEntrada = {
                                              "Region": _selectedRegion,
                                              "Estacion": nuevaEstacion,
                                            };

                                            final yaExiste = _addedEstacionesNotifier.value.any((element) =>
                                                element["Region"] == _selectedRegion &&
                                                element["Estacion"] == nuevaEstacion);

                                            if (yaExiste) {
                                              setState(() {
                                                _errorEstacion =
                                                    'La estación ya está agregada para esta región';
                                              });
                                              return;
                                            }


                                            final newList = List<Map<String, String>>.from(_addedEstacionesNotifier.value)..add(nuevaEntrada);
                                            _addedEstacionesNotifier.value = newList;
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
                            label: Text(
                              "${estacion['Estacion']}",
                            ),
                            backgroundColor: Colors.blue.shade100,
                            deleteIcon: const Icon(Icons.close, color: Colors.red),
                            onDeleted: () {
                              final newList = List<Map<String, String>>.from(estaciones)..remove(estacion);
                              _addedEstacionesNotifier.value = newList;
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
            ),
      ),
    );  
  }

  Widget _btnAddEstacion() {
    return Icon(
      Icons.add,
      size: 24.0,
      color: Colors.green[300],
    );
  }

  // BOTON REGISTRAR
  Widget _btnRegistrar(BuildContext context) {
    return ElevatedButton(
      onPressed: _isloading
      ? null 
      : () async {
        if (formKey.currentState!.validate() ?? false) {
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

          final username = _userNameController.text.trim();
          final name = _nameController.text.trim();
          final email = emailController.text.trim();
          final roleId = selectedRoleId;
          final estaciones = _addedEstacionesNotifier.value;

          final result = await Provider.of<AdduserProvider>(context, listen: false)
          .addUser(
            username, 
            name, 
            email, 
            roleId, 
            estaciones
          );

          if(result['success']){
            //Navigator.of(context).pop(true);
            await showFlushbar(context, result['message'], Colors.green.shade500, const Duration(seconds: 3));
            _resetForm();
          }else{
            await showFlushbar(context, result['message'], Colors.red.shade600, const Duration(seconds: 3));
          }
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.grey.shade300),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 38),
        ),
        backgroundColor: WidgetStateProperty.all<Color>(
            Colors.grey.shade300), // Color de fondo del botón
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
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
            return 'favor de ingresar un usuario';
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

  void _resetForm() {
    // Limpiar todos los TextEditingController
    _userNameController.clear();
    _nameController.clear();
    emailController.clear();
    passController.clear();
    _autocompleteController?.clear();
    _autocompleteController = null;

    // Reiniciar dropdowns
    _selectedRol = 'Seleccione un Rol';
    _selectedRegion = 'Seleccione una Región';
    _selectedDivision = 'Seleccione una División';
    _selectedEstacion = 'Seleccione una Estación';
    regionSelected = '';
    selectedRoleId = 0;
    // Limpiar estaciones agregadas
    _addedEstacionesNotifier.value = [];

    // Reiniciar errores
    _errorEstacion = null;

    // Opcional: pedir focus en un campo específico
    _stationFocusNode.unfocus();

    // Forzar rebuild
    setState(() {});
  }

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