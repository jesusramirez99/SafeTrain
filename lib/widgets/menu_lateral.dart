import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train/modales/carros_reglas_incumplidas.dart';
import 'package:safe_train/modales/modal_itinerario.dart';
import 'package:safe_train/modelos/change_notifier_provider.dart';
import 'package:safe_train/modelos/estaciones_provider.dart';
import 'package:safe_train/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train/modelos/ofrecimiento_tren_provider.dart';
import 'package:safe_train/modelos/rechazos_tren_provider.dart';
import 'package:safe_train/modelos/reglas_incumplidas_tren.dart';
import 'package:safe_train/modelos/tablas_tren_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';
import 'package:safe_train/modelos/validacion_reglas_provider.dart';
import 'package:safe_train/widgets/table_validation_history.dart';

class MenuLateral extends StatefulWidget {
  final VoidCallback toggleTableInfo;
  final VoidCallback toggleTableData;
  final VoidCallback toggleTableIndicator;
  final VoidCallback showValidateText;
  final VoidCallback showFecha;
  final VoidCallback showHora;

  const MenuLateral({
    super.key,
    required this.toggleTableInfo,
    required this.toggleTableData,
    required this.showValidateText,
    required this.showFecha,
    required this.showHora,
    required this.toggleTableIndicator,
  });

  @override
  State<MenuLateral> createState() => MenuLateralState();
}

enum TableView { none, indicators, information }

class MenuLateralState extends State<MenuLateral> {
  
  //bool _isButtonEnabled = true;
  TableView? _currentView;
  Offset? offset;

  @override
  Widget build(BuildContext context) {
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final menuWidth = isLaptop ? 150.0 : 190.0;
    final fontSize = isLaptop ? 10.5 : 13.0;
    final iconTextSpacing = isLaptop ? 6.0 : 10.0;
    return Container(
      width: menuWidth,
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Divider(),
          _btnIndicadores(fontSize, iconTextSpacing),
          const Divider(),
          _btnInfo(fontSize, iconTextSpacing),
          const Divider(),
          const SizedBox(height: 4.0),
          _btnValidar(context, fontSize, iconTextSpacing),
          const Divider(),
          const SizedBox(
            height: 4.0,
          ),
          _btnHistorialValidaciones(context, fontSize, iconTextSpacing),
          const Divider(),
          const SizedBox(height: 4.0),
          _btnItinerario(context, fontSize, iconTextSpacing),
          const Divider(),
        ],
      ),
    );
  }

  // BOTON INDCADORES DEL TREN
  Widget _btnIndicadores(double fontSize, double iconText) {
    final selectionNotifier = Provider.of<SelectionNotifier>(context);
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    return ValueListenableBuilder<int?>(
      valueListenable: selectionNotifier.selectedRowNotifier,
      builder: (context, selectedIndex, Widget? child) {
        bool isActive = _currentView == TableView.indicators;
        return TextButton(
          onPressed:
          selectedIndex == null || selectedIndex == -1
              ? null
              : () {
                  setState(() {
                    _currentView = isActive ? null : TableView.indicators;
                  });
                  widget.toggleTableIndicator();
                },
          style: _buttonStyle(selectedIndex),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  isActive ? Icons.article_outlined : Icons.analytics_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: iconText),
                Text(
                  isActive ? 'Datos del Tren' : 'Indicadores',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _btnInfo(double fontSize, double iconText) {
    final selectionNotifier = Provider.of<SelectionNotifier>(context);

    return ValueListenableBuilder<int?>(
      valueListenable: selectionNotifier.selectedRowNotifier,
      builder: (context, selectedIndex, Widget? child) {
        bool isActive = _currentView == TableView.information;
        return TextButton(
          onPressed: selectedIndex == null || selectedIndex == -1
              ? null
              : () {
                  setState(() {
                    _currentView = isActive ? null : TableView.information;
                  });
                  widget.toggleTableInfo();
                },
          style: _buttonStyle(selectedIndex),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  isActive
                      ? Icons.article_outlined
                      : Icons.perm_device_information,
                  color: Colors.white,
                ),
                SizedBox(width: iconText),
                Text(
                  isActive ? 'Datos del Tren' : 'Información del Tren',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatViolationRules(List<Map<String, dynamic>> reglasIncumplidas) {
  
    // Título de la sección
    String result = "Error de formación\n\n";

    // Conjunto para evitar duplicados
    Set<String> reglasUnicas = {};

    // Iterar sobre las reglas incumplidas
    for (var regla in reglasIncumplidas) {
      final reglaNombre = regla['regla'] ?? 'Regla desconocida';
      final descripcion = regla['Descripcion'] ?? 'Sin descripción';

      // Crear una clave única para evitar duplicados
      final claveUnica = "$reglaNombre - $descripcion";

      // Añadir al resultado si no está repetido
      if (!reglasUnicas.contains(claveUnica)) {
        reglasUnicas.add(claveUnica);
        result += "Regla: $reglaNombre\n $descripcion\n\n";
      }
    }

    return result.trim(); // Eliminar saltos de línea extra
  }

  // BOTON VALIDAR TREN
  Widget _btnValidar(BuildContext context, double fontSize, double iconText) {
    final selectionNotifier = Provider.of<SelectionNotifier>(context);
    final buttonStateNotifier = Provider.of<ButtonStateNotifier>(context);
    final selectedRow = Provider.of<SelectedRowModel>(context);

    final trenProvider = Provider.of<TrainModel>(context, listen: false);
    final tren = trenProvider.selectedTrain;
    final selectedEstacion =
        Provider.of<EstacionesProvider>(context, listen: false);
    final estacion = selectedEstacion.selectedEstacion;
    final validacionProvider = Provider.of<ValidacionReglasProvider>(context, listen: false);
    final userName = Provider.of<UserProvider>(context, listen: false);
    final user = userName.userName;

    return ValueListenableBuilder<int?>(
      valueListenable: selectionNotifier.selectedRowNotifier,
      builder: (context, selectedIndex, Widget? child) {
        return TextButton(
        
          onPressed: selectedRow.canValidate
                  ? () async {
                      try {
                        print('si pudo validar');
                        _showFlushbar(
                          context,
                          'Validando el tren...',
                          Colors.orange.shade400,
                          const Duration(seconds: 6),
                        );
                        await Future.delayed(const Duration(seconds: 5));

                        // Llamamos a validacionReglas para obtener las reglas validadas
                        bool isValid = await validacionProvider.validacionReglas(tren!, estacion!, '', user!, estacion);

                        print('Reglas: ${isValid}');
                        
                        if (isValid) {
                          _showFlushbar(context,
                            '${validacionProvider.resultadoMensaje}',
                            Colors.green.shade500,
                            const Duration(seconds: 6),
                          );

                          await Future.delayed(const Duration(seconds: 4));

                          // Ejecuta el cambio de tabla dentro de setState
                          setState(() {
                            widget.toggleTableData();
                          });

                          // Luego, refresca la tabla fuera de setState
                          await _refreshTable(context);

                          // Muestra el modal de confirmación
                          _showConfirmationDialog(
                            context,
                            validacionProvider.reglasValidadas,
                            validacionProvider.resultadoMensaje,
                          );
                        } else {
                          final mensaje = _formatViolationRules(validacionProvider.reglasIncumplidas);

                          print("Reglas incumplidas: ${validacionProvider.reglasIncumplidas}");
                          
                          _showFlushbarReglas(
                            context,
                            validacionProvider.reglasIncumplidas.isEmpty ? validacionProvider.resultadoMensaje : mensaje,
                            Colors.red.shade500,
                            const Duration(seconds: 5),
                          );

                          await Future.delayed(const Duration(seconds: 3));

                          await Provider.of<ReglasIncumplidasTrenProvider>(context, listen: false).fetchReglasIncumplidas(tren, estacion);

                          // Ahora mostramos el modal con los datos cargados
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return const ModalCarrosReglasIncumplidas(); // Modal para ver los carros que incumplen reglas
                            },
                          );
                        
                          setState(() {
                            widget.toggleTableInfo();
                            //_isButtonEnabled = false;
                          });
                        }
                      } catch (e) {
                        _showFlushbar(
                          context,
                          'Error al validar el tren: $e',
                          Colors.red,
                          const Duration(seconds: 6),
                        );
                        /*setState(() {
                          _isButtonEnabled = false;
                        });*/
                      }
                    }
                  : 
                  null,
          //style: _buttonStyle(selectedIndex, !_isButtonEnabled),
          style: _buttonStyleValidate(isDisabled: selectedRow.canValidate),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  Icons.train,
                  color: Colors.white,
                ),
                SizedBox(width: iconText),
                Text(
                  'Validar Tren',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // BOTON PARA HISTORIAL DE VALIDACIONES DEL TREN
  Widget _btnHistorialValidaciones(BuildContext context, double fontSize, double iconText) {
    return TextButton(
      onPressed: () async {
        final trainProvider = Provider.of<TrainModel>(context, listen: false);
        final trainId = trainProvider.selectedTrain;

        final provider = Provider.of<HistorialValidacionesProvider>(
          context,
          listen: false,
        );

        // Si el trainId es nulo o vacío, simplemente manda un Future vacío sin consulta
        Future<void> historialFuture;
        if (trainId != null && trainId.isNotEmpty) {
          historialFuture = provider.historialValidaciones(trainId);
        } else {
          historialFuture =
              Future.value(); // Un Future vacío para abrir el modal sin datos
        }

        // Abre el modal
        HistorialValidacionesModal.showHistorialValidacionesModal(
          context,
          historialFuture,
        );
      },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(
          const Color.fromRGBO(163, 159, 159, 0.8),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.add_task_outlined, color: Colors.white),
            SizedBox(width: iconText),
            Text(
              'Historial',
              style: TextStyle(fontSize: fontSize, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // BOTON PARA MOSTRAR EL ITINERARIO DEL TREN
  Widget _btnItinerario(BuildContext context, double fontSize, double iconText) {
    final selectionNotifier = Provider.of<SelectionNotifier>(context);
    return ValueListenableBuilder<int?>(
      valueListenable: selectionNotifier.selectedRowNotifier, 
      builder: (context, selectedIndex, Widget? child) {
        return TextButton(
          onPressed: (selectedIndex != null && selectedIndex != -1)
              ? () async {
                  // Obtén el ID del tren basado en el índice seleccionado
                  final trainProvider =
                      Provider.of<TrainModel>(context, listen: false);
                  final trainId = trainProvider.selectedTrain;

                  // Mostrar modal con el ID del tren
                  ItinerarioModal.mostrarModal(context, trainId!);
                }
              : null, // Deshabilita el botón si no hay selección
          style: _buttonStyle(selectedIndex),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.alt_route_rounded,
                color: Colors.white,
              ),
              SizedBox(width: iconText),
              Text(
                'Itinerario del Tren',
                style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ButtonStyle _buttonStyle(int? selectedIndex, [bool isDisabled = false]) {
    return ButtonStyle(
      overlayColor: MaterialStateProperty.all(
        const Color.fromRGBO(163, 159, 159, 0.8),
      ),
      mouseCursor: MaterialStateProperty.all<MouseCursor>(
        isDisabled || selectedIndex == null || selectedIndex == -1
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
      ),
      foregroundColor: MaterialStateProperty.all<Color>(
        isDisabled ? Colors.grey : Colors.white, // Color del texto del botón
      ),
    );
  }

  ButtonStyle _buttonStyleValidate({required bool isDisabled}) {
  return ButtonStyle(
    overlayColor: MaterialStateProperty.all(
      const Color.fromRGBO(163, 159, 159, 0.8),
    ),
    mouseCursor: MaterialStateProperty.all<MouseCursor>(
      isDisabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
    ),
    foregroundColor: MaterialStateProperty.all<Color>(
      isDisabled ? Colors.grey : Colors.white,
    ),
  );
}


  Future<void> _refreshTable(BuildContext context) async {
    final tren = Provider.of<TrainModel>(context, listen: false);
    final train = tren.selectedTrain;
    print('tren seleccionado: $train');

    final tableProvider =
        Provider.of<TablesTrainsProvider>(context, listen: false);
    final estacionProvider =
        Provider.of<EstacionesProvider>(context, listen: false);
    final estacion = estacionProvider.selectedEstacion;
    print('estacion selccionada: $estacion');

    await tableProvider.refreshTableDataTrain(context, train!, estacion!);
  }

  void _showConfirmationDialog(BuildContext context, List<Map<String, dynamic>> reglasValidadas, String resultadoMensaje) {
  showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            final screenSize = MediaQuery.of(context).size;
            final dialogWidth = screenSize.width * 0.4;
            final TextEditingController _observacionesController = TextEditingController();
            final dialogHeight = screenSize.height * 0.4;
            offset ??= Offset(
              (screenSize.width - dialogWidth) / 2,
              (screenSize.height - dialogHeight) / 2,
            );
            return Stack(
              children: [
                Positioned(
                  left: offset!.dx,
                  top: offset!.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setDialogState(() {
                        offset = offset! + details.delta;
                      });
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20.0),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Center(
                                      child: Text(
                                        'Formación Correcta.',
                                        style: TextStyle(
                                          fontSize: 21.0,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 45.0),
                                    Center(
                                      child: Text(
                                        resultadoMensaje,
                                        style: const TextStyle(
                                          fontSize: 22.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30.0),
                                    TextField(
                                      controller: _observacionesController,
                                      maxLength: 300,
                                      maxLines: 7,
                                      minLines: 3,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Observaciones',
                                        alignLabelWithHint: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '¿Deseas envíar el ofrecimiento del tren?',
                                  style: TextStyle(color: Colors.black, fontSize: 17.0),
                                ),
                                const SizedBox(height: 40.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade200,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        widget.toggleTableData(); // <- Llamar la función
                                      },
                                      child: const Text(
                                        'No enviar',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade200,
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );

                                        try {
                                          final userName = Provider.of<UserProvider>(context, listen: false);
                                          final user = userName.userName;

                                          final trenProvider = Provider.of<TrainModel>(context, listen: false);
                                          final tren = trenProvider.selectedTrain;

                                          final estacionProvider = Provider.of<EstacionesProvider>(context, listen: false);
                                          final estacion = estacionProvider.selectedEstacion;

                                          String fechaOfrecido = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());
                                          print(tren);
                                          

                                          await Provider.of<OfrecimientoTrenProvider>(context, listen: false)
                                              .ofrecimientoTren(
                                            context: context,
                                            tren: tren!,
                                            ofrecido: 'OK',
                                            ofrecidoPor: user!,
                                            fechaOfrecido: fechaOfrecido,
                                            estacion: estacion!,
                                            observaciones: _observacionesController.text,
                                          );

                                          Navigator.pop(context); // Cierra el loading
                                          Navigator.pop(context); // Cierra el modal
                                          _refreshTable(context);

                                          Provider.of<RechazosProvider>(context, listen: false)
                                              .refreshRechazos(context, user);
                                        } catch (error) {
                                          Navigator.pop(context); // Cierra el loading
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text('Hubo un problema al actualizar el ofrecimiento: $error'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cerrar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text(
                                        'Enviar ofrecimiento',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFlushbarReglas(BuildContext context, String message,
      Color backgroundColor, Duration duration) {
    Flushbar flushbar = Flushbar();
    flushbar = Flushbar(
      duration: null, // No se cierra automáticamente
      backgroundColor: backgroundColor,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(1.0),
      borderRadius: BorderRadius.circular(5.0),
      isDismissible: true,
      mainButton: IconButton(
        onPressed: () async {
          await _refreshTable(context);

          setState(() {
            widget.toggleTableInfo();
          });

          Future.delayed(const Duration(milliseconds: 300), () {
            flushbar.dismiss(true);
          });
        },
        icon: const Icon(
          Icons.close,
          color: Colors.white,
        ),
      ),
      messageText: SizedBox(
        //height: 140,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    // Agregar un listener para detectar el cierre
    flushbar.show(context).then((_) async {
      await _refreshTable(context);
      setState(() {
        widget.toggleTableInfo();
      });
    });
  }

  void _showFlushbar(BuildContext context, String message,
      Color backgroundColor, Duration duration) {
    Flushbar(
      duration: const Duration(seconds: 4),
      backgroundColor: backgroundColor,
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
