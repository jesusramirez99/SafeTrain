import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/change_notifier_provider.dart';
import 'package:safe_train/modelos/estaciones_provider.dart';
import 'package:safe_train/modelos/excel_download_provider.dart';
import 'package:safe_train/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train/modelos/tablas_tren_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';
import 'package:safe_train/widgets/btn_cancelar.dart';
import 'package:safe_train/widgets/campo_fecha.dart';
import 'package:safe_train/widgets/table_data_train.dart';
import 'package:safe_train/widgets/table_indicators_train.dart';
import 'package:safe_train/widgets/table_info_train.dart';
import 'package:safe_train/widgets/textfield_idtrain.dart';

class Cuerpo extends StatefulWidget {
  final bool showDataTrain;
  final bool showInfoTrain;
  final bool showIndicatorTrain;
  final bool showValidatorTrain;
  final bool showFecha;
  final bool showTime;

  const Cuerpo({
    super.key,
    required this.showDataTrain,
    required this.showInfoTrain,
    required this.showIndicatorTrain,
    required this.showValidatorTrain,
    required this.showFecha,
    required this.showTime,
  });

  @override
  State<Cuerpo> createState() => CuerpoState();
}

class CuerpoState extends State<Cuerpo> {
  bool _isHovered = false;
  bool _enabledIdTrain = false;
  bool _enabledFecha = false;
  bool _enabledEstacion = true;
  bool _iconSearchEnable = true;
  bool _iconPrintEnable = true;
  bool _iconCompareEnable = true;
  bool _showIndicatorTrain = false;
  bool _showDataTrain = true;
  bool _showInfoTrain = false;
  bool _isLoading = false;
  String _trenYFecha = '';
  

  List<Map<String, dynamic>> _dataTrain = [];

  int maxLength = 7;
  TextEditingController controllerEstacion = TextEditingController();
  String? _dropdownValue;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _idTrainController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void toggleIndicatorTrain() {
    setState(() {
      _showIndicatorTrain = !_showIndicatorTrain;
      _showDataTrain = !_showDataTrain;
      _showInfoTrain;
    });
  }

  void toggleDataTrain() {
    setState(() {
      _showDataTrain = !_showDataTrain;
      _showInfoTrain = !_showInfoTrain;
    });
  }

  void toggleInfoTrain() {
    setState(() {
      _showDataTrain = !_showDataTrain;
      _showInfoTrain = !_showInfoTrain;
    });
  }

  @override
  void initState() {
    super.initState();
    _dropdownValue = null; // Inicialmente no hay valor seleccionado
    Future.microtask(() =>
        Provider.of<EstacionesProvider>(context, listen: false)
            .fetchEstaciones());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _idTrainController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void _submit() {
    // Validaciones iniciales
    if (_idTrainController.text.isEmpty ||
        _fechaController.text.isEmpty ||
        _dropdownValue == 'ESTACION') {
      showFlushbar('Favor de ingresar todos los datos requeridos', Colors.red);
      return;
    } else {
      // Verificar que la estación seleccionada exista
      final estacionesProvider =
          Provider.of<EstacionesProvider>(context, listen: false);
      final estaciones = estacionesProvider.estaciones;

      if (!estaciones.any(
          (station) => station['id_estacion'] == controllerEstacion.text)) {
        // Mostrar mensaje de que la estación no existe
        Flushbar(
          duration: const Duration(seconds: 6),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
          margin: const EdgeInsets.all(1.0),
          borderRadius: BorderRadius.circular(5.0),
          messageText: const Text(
            'Estación seleccionada no existe, favor de verificar',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ).show(context);
        return;
      }

      // Si la estación existe, proceder con el resto de la lógica
      setState(() {
        _enabledEstacion = false;
        _toggleSearch();
        _isLoading = true;
      });

      String idTrain = _idTrainController.text;
      String fecha = _fechaController.text;

      if (fecha.length >= 2) {
        String dia = fecha.substring(0, 2);

        // Ajustar el formato del ID del tren con espacios
        String espacios = '';
        if (idTrain.length == 5) {
          espacios = '   ';
        } else if (idTrain.length == 6) {
          espacios = '  ';
        } else if (idTrain.length == 7) {
          espacios = ' ';
        } else if (idTrain.length == 8) {
          espacios = ''; // sin espacios
        }

        // Obtener el valor de FFCC
        final ffccProvider = Provider.of<FfccProvider>(context, listen: false);
        final ffcc = ffccProvider.selectedItem;

        // Obtener la estación seleccionada del proveedor
        final estacionesProvider =
            Provider.of<EstacionesProvider>(context, listen: false);
        final estaciones = estacionesProvider.selectedEstacion;

        // Construir la cadena de tren y fecha
        _trenYFecha = '$idTrain$espacios$dia';
        print('Datos del tren: $_trenYFecha');
        print('FFCC: $ffcc');

        // Llamar al método del proveedor TableDataTrainProvider
        final provider =
            Provider.of<TablesTrainsProvider>(context, listen: false);
        provider.tableDataTrain(context, _trenYFecha, ffcc, estaciones!);
      } else {
        print('La fecha debe tener al menos dos caracteres');
      }
    }
  }

  void showFlushbar(String message, Color color) {
    Flushbar(
      duration: const Duration(seconds: 6),
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      backgroundColor: color, // Agregar esta línea
      messageText: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    
    final estacionProvider = Provider.of<EstacionesProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Breakpoints simples
    final isLargeScreen = screenWidth > 1800;
    //final isMediumScreen = screenWidth > 1200 && screenWidth <= 1800;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const SizedBox(
                width: 30.0,
                height: 55.0,
              ),
              Expanded(
                child: Center(
                  child: textoListaTrenes('Validación de Trenes'),
                ),
              ),
            ],
          ),
          Center(
            child: Container(
              color: Colors.grey.shade600,
              height: 105.0,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: isLargeScreen ? 110.0 : 40.0),
                          textos('Tren'),
                          SizedBox(width: isLargeScreen ? 25.0 : 15.0),
                          TextFieldIdTrain(
                            focusNode: _focusNode,
                            idTrainController: _idTrainController,
                            isEnabled: !_enabledIdTrain,
                          ),
                          SizedBox(width: isLargeScreen? 40.0 : 20.0),
                          textos('Fecha'),
                          const SizedBox(width: 1.0),
                          Fecha(
                            fechaController: _fechaController,
                            isEnabled: !_enabledFecha,
                          ),
                          SizedBox(width: isLargeScreen? 40.0 : 10.0),    
                          _dropdownEstacion(context),
                          SizedBox(width: isLargeScreen? 40.0 : 20.0),
                          iconSearch(context),
                          SizedBox(width: isLargeScreen? 25.0 : 20.0),
                          const BotonCancelar(),
                          SizedBox(width: isLargeScreen? 50.0 : 60.0),
                          isLargeScreen
                          ? Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _iconCompareConsist(context),
                                  const SizedBox(width: 20.0),
                                  iconPrint(context),
                                  const SizedBox(width: 45.0),
                                  dateTime(context, "fecha"),
                                  const SizedBox(width: 10.0),
                                  const Text(
                                    '-',
                                    style: TextStyle(color: Colors.white, fontSize: 17.0),
                                  ),
                                  const SizedBox(width: 10.0),
                                  dateTime(context, "hora  hrs."),
                                ],
                              ),
                            )
                          : Row(                             
                                children: [
                                _iconCompareConsist(context),
                                const SizedBox(width: 15.0),
                                iconPrint(context),
                                SizedBox(width: isLargeScreen ? 20.0 : 15.0),
                                dateTime(context, "fecha"),
                                const SizedBox(width: 10.0),
                                const Text(
                                  '-',
                                  style: TextStyle(color: Colors.white, fontSize: 17.0),
                                ),
                                const SizedBox(width: 10.0),
                                dateTime(context, "hora  hrs."),
                                ],
                          ),
                             
                          SizedBox(width: isLargeScreen ? 80.0 : 10.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: <Widget>[
                if (widget.showIndicatorTrain)
                  IndicatorTrainTable(
                      trainInfo: _trenYFecha,
                      estacionActual: estacionProvider.selectedEstacion ??
                          'Estacion no seleccionada',
                      toggleTableIndicator: () {
                        setState(() {
                          toggleIndicatorTrain();
                        });
                      }),
                if (widget.showDataTrain)
                  DataTrainTable(
                      data: _dataTrain,
                      isLoading: _isLoading,
                      selectedTrain: _trenYFecha,
                      toggleTableData: () {
                        setState(() {
                          toggleDataTrain();
                        });
                      }),
                if (widget.showInfoTrain)
                  InfoTrainTable(
                    trainInfo: _trenYFecha,
                    estacion: estacionProvider.selectedEstacion ??
                        'Estación no seleccionada',
                    toggleTableInfo: () {
                      setState(() {
                        toggleInfoTrain();
                      });
                    },
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ESTILO TITULO VALIDACION DE TRENES
  Text textoListaTrenes(String texto) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade700,
      ),
    );
  }

  // Texto ID Tren y Fecha
  Text textos(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 15.0,
        fontWeight: FontWeight.w300,
        color: Colors.white,
      ),
    );
  }

  // ICONO BUSQUEDA DE TREN
  Widget iconSearch(BuildContext context) {
    final provider = Provider.of<HistorialValidacionesProvider>(context);
    final validationHistory = provider.validationHistory;
    if(validationHistory.isNotEmpty){
      validationHistory.clear();
    }

    return InkWell(
      onTap: _iconSearchEnable
          ? () {
              _submit();
            }
          : null,
      onHover: !_iconSearchEnable
          ? (value) {
              setState(() {
                _isHovered = false;
              });
            }
          : null,
      child: Icon(
        Icons.search,
        size: 35.0,
        color: _isHovered ? Colors.grey.shade300 : Colors.white,
      ),
    );
  }

  // ICONO PARA COMPARACION DE CONSIST
  Widget _iconCompareConsist(BuildContext context) {
    return Tooltip(
      message: 'Comparación de Consist',
      child: InkWell(
        onTap: _iconCompareEnable ? () {} : null,
        child: const Icon(
          Icons.difference,
          size: 23.0,
          color: Colors.white,
        ),
      ),
    );
  }

  // ICONO PARA IMPRIMIR EXCEL
  Widget iconPrint(BuildContext context) {
    final trenProvider = Provider.of<TrainModel>(context, listen: false);
    final tren = trenProvider.selectedTrain;

    final estacionProvider =
        Provider.of<EstacionesProvider>(context, listen: false);
    final estacion = estacionProvider.selectedEstacion;

    return Tooltip(
      message: 'Consist de tren',
      child: InkWell(
        onTap: _iconPrintEnable
            ? () {
                if (tren == null || tren.isEmpty) {
                  showFlushbar('No hay tren seleccionado', Colors.red);
                  return;
                }

                if (estacion == null || estacion.isEmpty) {
                  showFlushbar(
                      'No hay tren ni estacion seleccionada', Colors.red);
                  return;
                }

                showFlushbar(
                    'Descargando archivo para Tren: $tren', Colors.green);

                final excelProvider =
                    Provider.of<ExcelDownloadProvider>(context, listen: false);
                excelProvider.descargarExcel(tren, estacion);
              }
            : null,
        child: const Icon(
          Icons.print,
          size: 23.0,
          color: Colors.white,
        ),
      ),
    );
  }

  // Dropdown Estacion
  Widget _dropdownEstacion(BuildContext context) {
    return Consumer<EstacionesProvider>(
      builder: (context, estacionesProvider, _) {
        final estaciones = estacionesProvider.estaciones;
        final estacionesNombres = estaciones
            .map<String>((station) => station['id_estacion'] as String)
            .toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: 220.0,
          height: 45.0,
          child: estaciones.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    // Convertir texto de entrada y opciones a mayúsculas
                    final input = textEditingValue.text.toUpperCase();
                    return estacionesNombres.where((String option) {
                      return option.toUpperCase().contains(input);
                    });
                  },
                  onSelected: (String selection) {
                    final selectedStation = estaciones.firstWhere(
                      (station) => station['id_estacion'] == selection,
                    );

                    // Actualizamos la estación seleccionada en el provider
                    estacionesProvider
                        .updateSelectedEstacion(selectedStation['id_estacion']);

                    print(
                        'Estación seleccionada: ${selectedStation['id_estacion']}');
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onEditingComplete) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          enabled: _enabledEstacion,
                          onChanged: (text) {
                            // Si el texto supera el límite actual, recortarlo
                            if (text.length > maxLength) {
                              controller.value = controller.value.copyWith(
                                text: text.substring(0, maxLength),
                                selection:
                                    TextSelection.collapsed(offset: maxLength),
                              );
                            } else {
                              controller.value = controller.value.copyWith(
                                text: text.toUpperCase(),
                                selection: TextSelection.collapsed(
                                    offset: text.length),
                              );
                            }
                          },
                          decoration: _estiloDrop().copyWith(
                            hintText: 'ESTACION',
                            hintStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: const Icon(
                              Icons.house_rounded,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: SizedBox(
                          height: 200.0,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option.toUpperCase()),
                                onTap: () {
                                  onSelected(option);

                                  setState(() {
                                    maxLength = option.length;
                                  });

                                  controllerEstacion.text =
                                      option.toUpperCase();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  // Estilo de Dropdown
  InputDecoration _estiloDrop() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // WIDGET PARA LA FECHA Y HORA
  Widget dateTime(BuildContext context, String texto) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1800;
    final dateProvider = Provider.of<DateProvider>(context);

    String displayText = '';

    if (texto.toLowerCase() == "fecha") {
      displayText = dateProvider.currentDate;
    } else {
      displayText = "${dateProvider.currentTime} hrs.";
    }

    return Text(
      displayText,
      style: TextStyle(fontSize: isLargeScreen ? 17.0 : 15.0, color: Colors.white),
    );
  }

  // Método para controlar el botón buscar si está habilitado o deshabilitado
  void _toggleSearch() {
    setState(() {
      if (_idTrainController.text.isEmpty || _fechaController.text.isEmpty) {
        _iconSearchEnable = true;
      } else {
        _iconSearchEnable = false;
        _iconPrintEnable = true;
      }
      _enabledIdTrain = !_enabledIdTrain;
      _enabledFecha = !_enabledFecha;
    });
  }
}
