import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train/modales/motivos_rechazos_obs_id.dart';
import 'package:safe_train/modelos/change_notifier_provider.dart';
import 'package:safe_train/modelos/historico_validacion_trenes_provider.dart';
import 'package:safe_train/modelos/rechazos_observaciones_data_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';
import 'package:safe_train/widgets/custom_date.dart';

class HistorialValidacionesModal extends StatefulWidget {
  final Future<void>? historialFuture;

  const HistorialValidacionesModal({super.key, this.historialFuture});
  

  @override
  State<HistorialValidacionesModal> createState() => _HistorialValidacionesModalState();

  static Future<void> showHistorialValidacionesModal(
      BuildContext context, Future<void> historialFuture) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return HistorialValidacionesModal(historialFuture: historialFuture);
      },
    );
  }
}

class _HistorialValidacionesModalState extends State<HistorialValidacionesModal> {
  final singleController = CustomDatePickerController();
  final rangeController  = CustomDatePickerController();
  final TextEditingController controllertren = TextEditingController();
  final TextEditingController controllerestacion = TextEditingController();
  final ValueNotifier<bool> singleSelected = ValueNotifier(false);
  final ValueNotifier<bool> rangeSelected = ValueNotifier(false);


  @override
  void dispose() {
    controllertren.dispose();
    controllerestacion.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistorialValidacionesProvider>(context);
    final trenProvider = Provider.of<TrainModel>(context, listen: false);
    final tren = trenProvider.selectedTrain;


    return FutureBuilder(
      future: widget.historialFuture ?? Future.value(), // Manejar Future null
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              'Error: ${provider.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final validationHistory = provider.validationHistory;
        bool isScrollable = validationHistory.isNotEmpty;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 1500,/*MediaQuery.of(context).size.width * 0.9,*/
              maxHeight: 800,/*MediaQuery.of(context).size.height * 0.8,*/
            ),
            child: IntrinsicWidth(
              stepWidth: 100.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(tren ?? 'Sin Tren'),
                    const SizedBox(height: 16.0),


                    _buildSearchBar(context, controllertren, controllerestacion, singleController, rangeController),
                    const SizedBox(height: 22.0),



                    validationHistory.isNotEmpty
                        ? Flexible(
                            child: _buildDataTable(
                                validationHistory, isScrollable, context),
                          )
                        : const Center(
                            child: Text(
                              'No hay datos disponibles',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),

                          
                    const SizedBox(height: 20.0),
                    _buildCloseButton(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(
      BuildContext context,
      TextEditingController controllerTren,
      TextEditingController controllerestacion,
      CustomDatePickerController singleController,
      CustomDatePickerController rangeController) {
    // Función para realizar la búsqueda concatenando los dos campos
    Future<void> performSearch(BuildContext context) async {

      final trenId = controllerTren.text.trim();
      final estacion = controllerestacion.text.trim();
      String fecha = '';

      if(singleController.singleDate != null){
        fecha = DateFormat('dd').format(singleController.singleDate!);
      }else if(rangeController.range != null){
        final start = DateFormat('dd').format(rangeController.range!.start);
        final end = DateFormat('dd').format(rangeController.range!.end);

        fecha = '$start-$end';
      }

      if(trenId.isEmpty || fecha.isEmpty /*|| estacion.isEmpty*/){
        _showFlushbar(
          context, 
          'Favor de ingresar tren, fecha y estacion', 
          Colors.red.shade400,
        );
        return;
      }

      final provider = Provider.of<HistorialValidacionesProvider>(context, listen: false);
      String formattedTrenId = trenId;
      int trenIdLength = trenId.length;

      if (trenIdLength == 5) {
        formattedTrenId = '$trenId   '; // 3 espacios
      } else if (trenIdLength == 6) {
        formattedTrenId = '$trenId  '; // 2 espacios
      } else if (trenIdLength == 7) {
        formattedTrenId = '$trenId '; // 1 espacio
      } else if (trenIdLength == 8) {
        formattedTrenId = trenId; // Sin espacios
      }

      final searchQuery = '$formattedTrenId$fecha';
      print('busqueda:'+searchQuery);

      await provider.historialValidaciones(searchQuery);

      if(provider.validationHistory.isEmpty){
        _showFlushbar(
          context, 
          'El tren $searchQuery no existe', 
          Colors.red.shade400,
        );
      }

      /*if (trenId.isNotEmpty && fecha.isNotEmpty) {
        final provider = Provider.of<HistorialValidacionesProvider>(
          context,
          listen: false,
        );

        // Concatenar los espacios y la fecha
        String formattedTrenId = trenId;
        int trenIdLength = trenId.length;

        if (trenIdLength == 5) {
          formattedTrenId = '$trenId   '; // 3 espacios
        } else if (trenIdLength == 6) {
          formattedTrenId = '$trenId  '; // 2 espacios
        } else if (trenIdLength == 7) {
          formattedTrenId = '$trenId '; // 1 espacio
        } else if (trenIdLength == 8) {
          formattedTrenId = trenId; // Sin espacios
        }

        final searchQuery = '$formattedTrenId$fecha';

        // Realiza la búsqueda de los datos del tren
        await provider.historialValidaciones(searchQuery);

        // Verifica si la lista de historial de validaciones está vacía o no
        if (provider.validationHistory.isEmpty) {
          _showFlushbar(
              context,
              'El tren $searchQuery no existe, favor de validar',
              Colors.red.shade400);
        }
        return;
      } else {
        _showFlushbar(context, 'Favor de ingresar un tren válido y una fecha',
            Colors.red.shade400);
      }*/
    }
    
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: TextFormField(
            controller: controllerTren,
            onChanged: (text) {
              final upperText = text.toUpperCase();
              controllerTren.value = TextEditingValue(
                text: upperText,
                selection: TextSelection.collapsed(offset: upperText.length),
              );
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(7),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            decoration: const InputDecoration(
              labelText: 'ID Tren',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12.0), // Espacio entre los dos campos
        
        // TextFormField para Fecha, permite solo 2 caracteres numéricos
        Row(
          children: [
            SizedBox(
              width: 150,
              child: ValueListenableBuilder<bool>(
                valueListenable: rangeSelected,
                builder: (_, range, __) {
                  return CustomDatePicker(
                    mode: PickerMode.single,
                    label: 'Fecha',
                    controller: singleController,
                    enabled: !range,
                    onSingle: (date) {
                      singleSelected.value = date != null;
                      if (date != null) rangeSelected.value = false;
                    },
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            SizedBox(
              width: 250,
              child: ValueListenableBuilder<bool>(
                valueListenable: singleSelected,
                builder: (_, single, __) {
                  return CustomDatePicker(
                    mode: PickerMode.range,
                    label: 'Periodo',
                    controller: rangeController,
                    enabled: !single,
                    onRange: (range) {
                      rangeSelected.value = range != null;
                      if (range != null) singleSelected.value = false;
                    },
                  );
                },
              ),
            ),
          ],
        ),

        /*SizedBox(
          width: 70,
          child: TextFormField(
            controller: controllerFecha,
            inputFormatters: [
              LengthLimitingTextInputFormatter(2),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              labelText: 'Fecha',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onFieldSubmitted: (value) async {
              final trenId = controllerTren.text.trim();
              final fecha = controllerFecha.text.trim();
              //final estacion = 
              await performSearch(context, trenId, fecha);
            },
          ),
        ),*/

        const SizedBox(width: 15.0),

        SizedBox(
          width: 100,
          child: TextFormField(
            controller: controllerestacion,
            onChanged: (text) {
              final upperText = text.toUpperCase();
              controllerestacion.value = TextEditingValue(
                text: upperText,
                selection: TextSelection.collapsed(offset: upperText.length),
              );
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(7),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]'))
            ],
            decoration: const InputDecoration(
              labelText: 'Estación',
              border: OutlineInputBorder(),
            ),
          ),
        ),

        const SizedBox(width: 15.0),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => performSearch(context),
        ),


        const SizedBox(width: 12.0),
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.red),
          onPressed: () {
            controllerTren.clear();
            controllerestacion.clear();
            singleController.clear();
            rangeController.clear();
            singleSelected.value = false;
            rangeSelected.value = false;
          },
        ),
        const SizedBox(width: 550),
        iconPrint(context),
      ],
    );  
  }

  Widget _buildTitle(String tren) {
    return const Center(
      child: Text(
        'Historial Validación de Trenes',
        style: TextStyle(
          fontSize: 21.0,
          color: Color.fromARGB(255, 103, 102, 102),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }



  Widget _buildDataTable(List<Map<String, dynamic>> validationHistory,
      bool isScrollable, BuildContext context) {
        final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    return SizedBox(
      height: 900,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade400, width: 1.0),
            columnSpacing: 10.0,
            dataRowHeight: 65.0,
            headingRowColor: MaterialStateProperty.all(Colors.black),
            columns: _buildTableHeaders(context),
            rows: validationHistory
                .map((record) => _buildDataRow(record, context))
                .toList(),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableHeaders(context) {
    return [
      _buildHeaderColumn('Tren', context),
      _buildHeaderColumn('Estación\nOrigen', context),
      _buildHeaderColumn('Estación\nDestino', context),
      _buildHeaderColumn('Estación\nActual', context),
      _buildHeaderColumn('Total\nCarros', context),
      /*_buildHeaderColumn('Cargados', context),
      _buildHeaderColumn('Vacíos', context),*/
      _buildHeaderColumn('Estatus\nValidación', context),
      _buildHeaderColumn('Fecha\nValidado', context),
      /*_buildHeaderColumn('Ofrecido\nPor', context),*/
      _buildHeaderColumn('Fecha\nOfrecido', context),
      _buildHeaderColumn('Estatus\nCCO', context),
      _buildHeaderColumn('Fecha CCO\nAutorizado/Rechazado', context),
      _buildHeaderColumn('Fecha Envio\nde Llamado', context),
      _buildHeaderColumn('Fecha\nLlamado', context),
      _buildHeaderColumn('Salida de \nTerminal', context),

    ];
  }

  DataColumn _buildHeaderColumn(String label, BuildContext context) {
    return DataColumn(
      label: Expanded(
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(Map<String, dynamic> record, BuildContext context) {
    //final trenProvider = Provider.of<MotRechazoObs>(context, listen: true);
    //final idProvider = Provider.of<IdTren>(context, listen: false);

    final int id = record['ID'];
    final String? validado = record['validado'];
    final String? autorizado = record['autorizado'];
    //final String motivo = record['motivoRechazo'] ?? 'Sin motivo';
    //final String obs = record['observaciones'] ?? 'Sin observaciones';

    //final bool isSelected = trenProvider.idTrain == id;

    return DataRow(
      /*selected: isSelected,
      onSelectChanged: (selected) {
        if (selected == true) {
          trenProvider.setSelectedTrain(id, motivo, obs);
          idProvider.setSelectedID(id.toString());
          print("✅ ID seleccionado y guardado en Provider: $id");
        } else {
          trenProvider.clearData();
          idProvider.setSelectedID(0.toString());
          print("🗑 ID limpiado en Provider");
        }
        print('ID seleccionado en la tabla: $id');
      },*/
      cells: [
        _buildDataCell(record['IdTren'] ?? '', Colors.black, context),
        _buildDataCell(record['origen'] ?? '', Colors.black, context),
        _buildDataCell(record['destino'] ?? '', Colors.black, context),
        _buildDataCell(record['estacion_actual'] ?? '', Colors.black, context),
        _buildDataCellCars(
          '${'Cargados'.padRight(15)}${record['cargados'] ?? ''}\n'
          '${'Vacios'.padRight(18)}${record['vacios'] ?? ''}\n'
          '${'Total'.padRight(20)}${record['carros'] ?? ''}\n',
          Colors.black, context
        ),

        // 🔥 "Validado" en rojo si es "Rechazado" o "Error de formación"
        _buildDataCell(
            validado ?? '',
            (validado == 'Rechazado' || validado == 'Error de formación')
                ? Colors.red
                : Colors.black,
            context),

        // 🔥 "Fecha Validado" en rojo si "Validado" es "Error de formación"
        _buildCellDateString(
            record['validado_por']?.toString() ?? '',
            formattedDateCell(
              date: record['fecha_validado']?.toString() ?? '',
              format: 'dd/MM/yyyy \n HH:mm',
            ),
            Colors.black,
            context
        ),

        _buildCellDateString(
          record['ofrecido_por']?.toString() ?? '',
          formattedDateCell(
            date: record['fecha_ofrecido']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm',
          ),
          Colors.black,
          context
        ),

        // 🔥 "Estatus CCO" en rojo solo si es "Rechazado"
        _buildStatusCell(
          autorizado ?? 'Autorizado',
          autorizado == 'Rechazado' ? Colors.red : Colors.black,
          context,
          id,
        ),

        // 🔥 "Fecha Autorizado" en rojo si "Estatus CCO" es "Rechazado"
        _buildCellDateString(
          record['autorizado_por']?.toString() ?? '',
          formattedDateCell(
            date: record['fecha_autorizado']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm',
          ),
          Colors.black,
          context
        ),

        _buildCellDateString(
          record['llamado_por']?.toString() ?? '', 
          formattedDateCell(
            date: record['fecha_llamado']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm',
          ), 
          Colors.black, 
          context
        ),

        _buildCellDateString(
          record['llamado_por']?.toString() ?? '', 
          formattedDateCell(
            date: record['fecha_llamado']?.toString() ?? '',
            format: 'dd/MM/yyyy \n HH:mm',
          ), 
          Colors.black, 
          context
        ),

        // Fecha llamada completada
        buildCellExitterminal(
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RC2 ${record['fecha_salida_rc2']?.toString() ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10), // Espaciado entre las dos celdas
              Text(
                'AEI ${record['fecha_salida_lector']?.toString() ?? ''}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

          
      ],
    );

    
  }

  DataCell buildCellExitterminal({
    required Widget widget,
  }) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Primer texto
            widget,
          ],
        ),
      ),
    );
  }

 // 🔥 Función para construir la celda "Estatus CCO" (autorizado)
  DataCell _buildStatusCell(
      String text, Color textColor, BuildContext context, int trenId) {
    final idProvider = Provider.of<IdTren>(context, listen: false);
    final rechazosProvider =
        Provider.of<RechazosObservacionesData>(context, listen: false);

    return DataCell(
      MouseRegion(
        cursor: text == 'Rechazado'
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: () async {
            if (text == 'Rechazado') {
              idProvider.setSelectedID(trenId.toString());
              print("🔍 ID almacenado en Provider: ${idProvider.idTren}");

              final int? iD = idProvider.idTren;

              if (iD != null) {
                await rechazosProvider.fetchHistorico(iD);

                if (context.mounted) {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => const RechazoObsTren(),
                  );
                }
              }
              return;
            }
          },
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: textColor,
                decoration:
                    text == 'Rechazado' ? TextDecoration.underline : null,
                decorationColor: text == 'Rechazado'? Colors.red : null,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCellCars(String text, Color textColor, BuildContext context){
    return DataCell(
      Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }

  DataCell _buildCellDateString(
    String text,
    Widget widget,
    Color color,
    BuildContext context
  ) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Primer texto
            widget,
            Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 Función para construir celdas con formato
  DataCell _buildDataCell(String value, Color textColor, BuildContext context) {
    return DataCell(
      Container(
        width: 85.0, // Asignar el ancho específico
        alignment: Alignment.center, // Centrar el contenido
        color: Colors.transparent, // No color de fondo
        child: Text(
          value.contains('T') ? _formatDateTime(value) : value.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    try {
      // Parseamos la fecha al formato ISO 8601
      final parsedDate = DateTime.parse(dateTimeString);
      // Formateamos la fecha y hora como dd/MM/yyyy HH:mm
      return DateFormat('dd/MM/yyyy \n HH:mm').format(parsedDate);
    } catch (e) {
      // En caso de que falle el formato, devolvemos la cadena original
      return dateTimeString;
    }
  }

  Widget formattedDateCell({
      required String date,
      String format = 'dd/MM/yyyy \n HH:mm',
      Color textColor = Colors.black,
    }) {
      if (date.isEmpty) {
        return const Text('');
      }

      try {
        // Parsear la fecha y formatearla
        DateTime dateTime = DateTime.parse(date);
        String formattedDate = DateFormat(format).format(dateTime);

        return Center(
          child: Text(
            formattedDate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        );
      } catch (e) {
        return Center(
          child: Text(
            date,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }
    }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(
          'Cerrar',
          style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade400,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget iconPrint(BuildContext context) {
    /*final trenProvider = Provider.of<TrainModel>(context, listen: false);
    final tren = trenProvider.selectedTrain;
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final estacionProvider =
        Provider.of<EstacionesProvider>(context, listen: false);
    final estacion = estacionProvider.selectedEstacion;*/
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');

    return Tooltip(
      message: 'Consist de tren',
      child: InkWell(
        /*onTap: _iconPrintEnable
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
            : null,*/
        child: Icon(
          Icons.print,
          size: isLaptop? 28.0 : 23.0,
          color: Colors.black,
        ),
      ),
    );
  }

  void _showFlushbar(
      BuildContext context, String message, Color backgroundColor) {
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
    ).show(context); // Agrega esta línea para mostrar el Flushbar
  }
}
