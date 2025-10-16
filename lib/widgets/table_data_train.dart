import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:safe_train/modales/mostrar_rechazo_obs_trenes.dart';
import 'package:safe_train/modelos/change_notifier_provider.dart';
import 'package:safe_train/modelos/estaciones_provider.dart';
import 'package:safe_train/modelos/ofrecimiento_tren_provider.dart';
import 'package:safe_train/modelos/rechazos_tren_provider.dart';
import 'package:safe_train/modelos/tablas_tren_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';

class DataTrainTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final bool isLoading;
  final String selectedTrain;
  final VoidCallback toggleTableData;
  

  const DataTrainTable({
    super.key,
    required this.selectedTrain,
    required this.toggleTableData,
    required this.data,
    required this.isLoading,
  });

  @override
  State<DataTrainTable> createState() => _DataTrainTableState();

}

class _DataTrainTableState extends State<DataTrainTable> {
  int _selectedRowIndex = -1; // Inicializa la variable para la fila seleccionada
  String _selectedTrain = '';
  String _selectedEstation = '';
  String _filterStation = "";
  String _selectedOferred = '';
  String _selectedStatus = '';
  late final ScrollController _horizontalScrollController;
  Timer? _timer; // 👈 para guardar el timer

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    final providerDataTrain = Provider.of<TablesTrainsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.userName ?? '';
    providerDataTrain.tableTrainsOffered(context, user);
     _timer = Timer.periodic(const Duration(minutes: 2), (_) {
      providerDataTrain.tableTrainsOffered(context, user);
    });
    
  }

  @override
  void dispose() {
    _timer?.cancel();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //final ScrollController _horizontalScrollController = ScrollController();
    final isLargeScreen = screenWidth > 1800;
    //final rowSelected = Provider.of<SelectionNotifier>(context);
    final providerDataTrain = Provider.of<TablesTrainsProvider>(context);
    /*final trainModel = Provider.of<TrainModel>(context, listen: false);
    final estacion = Provider.of<EstacionesProvider>(context, listen: false);
    final trainData = providerDataTrain.firstTrain;*/
    //print(providerDataTrain.trainData);

    return SizedBox(
      width: isLargeScreen? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.8,
      height: isLargeScreen? MediaQuery.of(context).size.height * 0.7 : MediaQuery.of(context).size.height * 0.6,
      child: providerDataTrain.isLoading ? const Center(child: CircularProgressIndicator()) : providerDataTrain.trainData? _buildTableDataTrain() : _buildTableStatusTrainsOffered()
          
    );
  }

  //Tabla de trenes ofrecidos
  Widget _buildTableStatusTrainsOffered(){
    final ScrollController _horizontalScrollController = ScrollController();
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final providerDataTrain = Provider.of<TablesTrainsProvider>(context);
    final filteredTrains = _filterStation.isEmpty
      ? providerDataTrain.dataTrainsOffered
      : providerDataTrain.dataTrainsOffered
          .where((train) => train['estacion_actual']
              .toString()
              .toLowerCase()
              .contains(_filterStation.toLowerCase()))
          .toList();


    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Text(
              'Estatus Trenes Ofrecidos',
              style: TextStyle(
                fontSize: isLaptop? 18.0 : 22.0,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: isLaptop? 190.0 : 230.0,
              // mismo ancho que la primera columna de la tabla
              child: TextField(
                style: TextStyle(
                  fontSize: isLaptop? 14.0 : 16.0,
                ),
                decoration: InputDecoration(
                  labelText: "Buscar estación",
                  labelStyle: TextStyle(fontSize: isLaptop? 14.0 : 16.0),
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: isLaptop? 5 : 8, vertical: isLaptop? 5 : 8),
                ),
                onChanged: (value) {
                  setState(() {
                    _filterStation = value;
                  });
                },
              ),
            ),
          ),
        ),

        LayoutBuilder(
          builder: (context, constraints) {
            const double rowHeight = 70;
            double screenHeight = MediaQuery.of(context).size.height;
            double reserveSpace = 360;
            double maxHeight = isLaptop ? screenHeight - reserveSpace : 800 ;
            const double headingHeight = 48;
            //double maxHeight =  isLaptop? 238 : 800;
            final tableHeight = (filteredTrains.length * rowHeight + headingHeight).clamp(0, maxHeight);
            
            return SizedBox(
              height: tableHeight.toDouble(),
              child: DataTable2(
                headingRowHeight: headingHeight,
                dataRowHeight: rowHeight,
                horizontalMargin: 8,
                columnSpacing: 12,
                minWidth: 1530,
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey.shade400, width: 1),
                  verticalInside: BorderSide(color: Colors.grey.shade400, width: 1),
                ),
                decoration: _cabeceraTabla(),
                columns: _buildColumnsTrainStatusTrainsOffered(),
                rows: filteredTrains.map((train) => DataRow(
                  color: MaterialStateColor.resolveWith((states) =>
                      states.contains(MaterialState.selected)
                          ? const Color.fromARGB(255, 226, 237, 247)
                          : (filteredTrains.indexOf(train) % 2 == 0 ? Colors.white : Colors.grey.shade100)
                  ),
                  cells: _buildCellsTrainStatusTrainsOffered(train),
                )).toList(),
              ),
            );
          },
        ),
      ],
    );
  }


  //Tabla de datos de tren
  Widget _buildTableDataTrain(){   
    final ScrollController _horizontalScrollController = ScrollController();
    final isLaptop = ResponsiveBreakpoints.of(context).equals('LAPTOP');
    final rowSelected = Provider.of<SelectionNotifier>(context);
    final providerDataTrain = Provider.of<TablesTrainsProvider>(context);
    final trainModel = Provider.of<TrainModel>(context, listen: false);
    final estacion = Provider.of<EstacionesProvider>(context, listen: false);
    final trainData = providerDataTrain.firstTrain;  
      //Widget de tabla de Datos de tren y responsivo
          return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Datos del Tren: ${trainData?['IdTren'] ?? ''}',
                          style: TextStyle(
                            fontSize: isLaptop? 18.0 : 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 100),
                        Text(
                          'Estación Origen: ${trainData?['origen'] ?? ''}',
                          style: TextStyle(
                            fontSize: isLaptop? 18.0 : 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const SizedBox(width: 100),
                        Text(
                          'Estación Destino: ${trainData?['destino'] ?? ''}',
                          style: TextStyle(
                            fontSize: isLaptop? 18.0 : 22.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                isLaptop
                ?
                //TABLA DE DATOS DE TREN
                Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1000,
                      ),
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all<Color>(Colors.grey),
                          trackColor: WidgetStateProperty.all<Color>(Colors.grey.shade300),
                          trackBorderColor: WidgetStateProperty.all<Color>(Colors.grey.shade400),
                          radius: const Radius.circular(8),
                          thickness: WidgetStateProperty.all<double>(8.0),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          trackVisibility: true,
                          controller: _horizontalScrollController,
                          child: SingleChildScrollView(
                            controller: _horizontalScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: DataTable(
                                columnSpacing: 10.0,
                                dataRowHeight: 75.0,
                                decoration: _cabeceraTabla(),
                                columns: _buildColumns(),
                                rows: List<DataRow>.generate(
                                  providerDataTrain.dataTrain.length,
                                  (index) => DataRow(
                                    selected: index == _selectedRowIndex,
                                    onSelectChanged: (isSelected) {
                                      final selectedRowNotifier = Provider.of<SelectedRowModel>(context, listen: false);
                                      setState(() {
                                        if (isSelected != null && isSelected) {
                                          _selectedRowIndex = index;
                                          print("indes: ${_selectedRowIndex}");
                                          _selectedOferred = providerDataTrain.dataTrain[index]['ofrecido_por'].toString();
                                          _selectedStatus = providerDataTrain.dataTrain[index]['autorizado'].toString();
                                          _selectedTrain = providerDataTrain.dataTrain[index]['IdTren'].toString();
                                          _selectedEstation = providerDataTrain.dataTrain[index]['estacion_actual'].toString();
                                          print('Estacion: $_selectedEstation');
                                          print('Tren: $_selectedTrain');
                                        
                                          selectedRowNotifier.setSelectedRow(
                                            index: _selectedRowIndex, 
                                            status: _selectedStatus, 
                                            offered: _selectedOferred
                                          );

                                          trainModel.setSelectedTrain(_selectedTrain);
                                          estacion.updateSelectedEstacion(_selectedEstation);
                                          rowSelected.updateSelectedRow(index);

                                        } else {
                                          _selectedRowIndex = -1;
                                          _selectedStatus = '';
                                          _selectedOferred = '';
                                          _selectedTrain = '';
                                          rowSelected.updateSelectedRow(null);
                                          selectedRowNotifier.clearSelection();

                                          print('Fila deseleccionada: $_selectedRowIndex');
                                          print('Tren: $_selectedTrain');
                                        }
                                      });
                                      // tu lógica de selección aquí
                                    },
                                    color: MaterialStateColor.resolveWith(
                                      (Set<MaterialState> states) {
                                        if (states.contains(MaterialState.selected)) {
                                          return const Color.fromARGB(255, 226, 237, 247);
                                        } else {
                                          return index % 2 == 0 ? Colors.white : Colors.white;
                                        }
                                      },
                                    ),
                                    cells: _buildCells(providerDataTrain.dataTrain[index]),
                                  ),
                                ),
                                border: TableBorder(
                                  horizontalInside: BorderSide(color: Colors.grey.shade400, width: 1),
                                  verticalInside: BorderSide(color: Colors.grey.shade400, width: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                )
                
                :

                  DataTable(
                    dataRowHeight: 65.0,
                    decoration: _cabeceraTabla(),
                    columns: _buildColumns(),
                    rows: List<DataRow>.generate(
                      providerDataTrain.dataTrain.length,
                      (index) => DataRow(
                        
                        selected: index == _selectedRowIndex,
                        onSelectChanged: (isSelected) {
                          final selectedRowNotifier = Provider.of<SelectedRowModel>(context, listen: false);
                          

                          setState(() {
                            if (isSelected != null && isSelected) {
                              _selectedRowIndex = index;
                              print("indes: ${_selectedRowIndex}");
                              _selectedOferred = providerDataTrain.dataTrain[index]['ofrecido_por'].toString();
                              _selectedStatus = providerDataTrain.dataTrain[index]['autorizado'].toString();
                              _selectedTrain = providerDataTrain.dataTrain[index]['IdTren'].toString();
                              _selectedEstation = providerDataTrain.dataTrain[index]['estacion_actual'].toString();
                              print('Estacion: $_selectedEstation');
                              print('Tren: $_selectedTrain');
                             
                              selectedRowNotifier.setSelectedRow(
                                index: _selectedRowIndex, 
                                status: _selectedStatus, 
                                offered: _selectedOferred
                              );

                              trainModel.setSelectedTrain(_selectedTrain);
                              estacion.updateSelectedEstacion(_selectedEstation);
                              rowSelected.updateSelectedRow(index);

                            } else {
                              _selectedRowIndex = -1;
                              _selectedStatus = '';
                              _selectedOferred = '';
                              _selectedTrain = '';
                              rowSelected.updateSelectedRow(null);
                              selectedRowNotifier.clearSelection();

                              print('Fila deseleccionada: $_selectedRowIndex');
                              print('Tren: $_selectedTrain');
                            }
                          });
                        },
                        color: WidgetStateColor.resolveWith(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color.fromARGB(255, 226, 237, 247);
                            } else {
                              return index % 2 == 0 ? Colors.white : Colors.white;
                            }
                          },
                        ),
                        cells: _buildCells(providerDataTrain.dataTrain[index]),
                      ),
                    ),
                    border: TableBorder(
                      horizontalInside: BorderSide(color: Colors.grey.shade400, width: 1),
                      verticalInside: BorderSide(color: Colors.grey.shade400, width: 1),
                    ),
                  )

                  
              ],
            );
  }


  List<DataColumn> _buildColumnsTrainStatusTrainsOffered(){
    return [
      DataColumn2(label: _buildHeaderCell('Tren'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Estacion\nActual'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Carros'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Validado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha\nValidado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha\nOfrecido'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Estatus\nCCO'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha CCO\nAutorizado / Rechazado'), size: ColumnSize.M),
      DataColumn2(label: _buildHeaderCell('Fecha Envío\n de Llamado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Fecha\nLlamado'), size: ColumnSize.S),
      DataColumn2(label: _buildHeaderCell('Registro de \nSalida'), size: ColumnSize.S)
    ];
  }

  List<DataColumn> _buildColumns() {
    return [
      //DataColumn(label: _buildHeaderCell('Tren')),
      //DataColumn(label: _buildHeaderCell('Estación\nOrigen')),
      //DataColumn(label: _buildHeaderCell('Estación\nDestino')),
      DataColumn(label: _buildHeaderCell('Estación\nActual')),
      DataColumn(label: _buildHeaderCell('Carros')),
      //DataColumn(label: _buildHeaderCell('Cargados')),
      //DataColumn(label: _buildHeaderCell('Vacíos')),
      DataColumn(label: _buildHeaderCell('Validado')),
      DataColumn(label: _buildHeaderCell('Fecha\nValidado')),
      //DataColumn(label: _buildHeaderCell('Ofrecido\npor')),
      DataColumn(label: _buildHeaderCell('Fecha\nOfrecido')),
      DataColumn(label: _buildHeaderCell('Estatus\nCCO')),
      DataColumn(label: _buildHeaderCell('Fecha CCO\nAutorizado / Rechazado')),
      //DataColumn(label: _buildHeaderCell('Autorizado')),
      DataColumn(label: _buildHeaderCell('Fecha Envío\n de Llamado')),
      DataColumn(label: _buildHeaderCell('Fecha\nLlamado')),
      DataColumn(label: _buildHeaderCell('Registro de \nSalida'))
    ];
  }

  List<DataCell> _buildCellsTrainStatusTrainsOffered(Map<String, dynamic> data){
    Provider.of<TablesTrainsProvider>(context);
    Provider.of<TrainModel>(context, listen: false);

   // FORMATEO DE LA FECHA
    Widget formattedDateCellTrainsOffered({
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

    return [
      _buildCell(data['IdTren']?.toString() ?? '', Colors.black),
      _buildCell(data['estacion_actual']?.toString() ?? '', Colors.black),
      _buildCell(
        '${'Cargados'.padRight(15)}${data['cargados'] ?? ''}\n'
        '${'Vacios'.padRight(18)}${data['vacios'] ?? ''}\n'
        '${'Total'.padRight(20)}${data['carros'] ?? ''}\n',
        Colors.black,
      ),

      // Validado
      _buildValidatedCell(
          data['validado']?.toString() ?? '',
          data['autorizado']?.toString() ?? '',
          data['ofrecido_por']?.toString() ?? ''),

    
      // Fecha Vaidado
      _buildCellDateString(
        text: data['validado_por']?.toString() ?? '',
        widget: formattedDateCellTrainsOffered(
          date: data['fecha_validado']?.toString() ?? '',
          format: 'dd/MM/yyyy \nHH:mm',
        ),
      ),

      /*DataCell(
        formattedDateCell(
          date: data['fecha_validado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),*/

      // Fecha Ofrecido
      _buildCellDateStringObservationsOffered(
        messageObservations: data['observ_ofrecimiento'] ?? '' ,
        text: data['ofrecido_por']?.toString() ?? '', 
        widget: data['ofrecido_por'] == ''
              ? const SizedBox() // Celda vacía si no hay nada en la celda
              : formattedDateCellTrainsOffered(
                  date: data['fecha_ofrecido']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
        context: context,
        id: data['IdTren'].toString(),
      ),
      // Estatus CCO - Autorizado / Rechazado
      _buildStatusCell(
        data['autorizado']?.toString() ?? 'Autorizado',
        data['autorizado'] == 'Autorizado' ? Colors.green : Colors.red,
        context,
        data['IdTren']?.toString(),
      ),

      // Fecha Autorizado / Rechazado
      _buildCellDateString(
        text: data['autorizado_por']?.toString() ?? '', 
        widget: formattedDateCellTrainsOffered(
          date: data['fecha_autorizado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

   
      
      // Fecha Envio de Llamado
      _buildCellDateString(
        text: data['llamado_por']?.toString() ?? '', 
        widget: data['autorizado'] == 'Rechazado'
              ? const SizedBox()
              : formattedDateCellTrainsOffered(
                  date: data['fecha_llamado']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
      ),

      // Fecha Llamado
      _buildCellDateString(
        text: data['llamado_por']?.toString() ?? '', 
        widget: data['autorizado'] == 'Rechazado'
              ? const SizedBox()
              : formattedDateCellTrainsOffered(
                  date: data['fecha_llamado']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
      ),

      // Fecha llamada completada
      _buildCellDateString(
        text: '', 
        widget: formattedDateCellTrainsOffered(
          date: '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),
    ];    
  }



  //CELDA PARA TABLA DE INFORMACION DE TREN
  List<DataCell> _buildCells(Map<String, dynamic> data) {
    Provider.of<TablesTrainsProvider>(context);
    Provider.of<TrainModel>(context, listen: false);

    // FORMATEO DE LA FECHA
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

    // Construir la lista de celdas
    return [
      //_buildCell(data['IdTren']?.toString() ?? '', Colors.black),
      //_buildCell(data['origen']?.toString() ?? '', Colors.black),
      //_buildCell(data['destino']?.toString() ?? '', Colors.black),
      _buildCell(data['estacion_actual']?.toString() ?? '', Colors.black),
      //_buildCell(data['carros']?.toString() ?? '', Colors.black),
      //_buildCell(data['cargados']?.toString() ?? '', Colors.black),
      //_buildCell(data['vacios']?.toString() ?? '', Colors.black),
      _buildCell(
        '${'Cargados'.padRight(15)}${data['cargados'] ?? ''}\n'
        '${'Vacios'.padRight(18)}${data['vacios'] ?? ''}\n'
        '${'Total'.padRight(20)}${data['carros'] ?? ''}\n',
        Colors.black,
      ),

      // Validado
      _buildValidatedCell(
          data['validado']?.toString() ?? '',
          data['autorizado']?.toString() ?? '',
          data['ofrecido_por']?.toString() ?? ''),

      // Fecha Validado
      _buildCellDateString(
        text: data['validado_por']?.toString() ?? '',
        widget: formattedDateCell(
          date: data['fecha_validado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Ofrecido Por
      //_buildCell(data['ofrecido_por']?.toString() ?? '', Colors.black),

      // Fecha Ofrecido
      _buildCellDateStringObservations(
        messageObservations: data['observ_ofrecimiento'] ?? '',
        text: data['ofrecido_por']?.toString() ?? '',
        widget: data['ofrecido_por'] == ''
              ? const SizedBox() // Celda vacía si no hay nada en la celda
              : formattedDateCell(
                  date: data['fecha_ofrecido']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
        context: context,
        id: data['IdTren'],
      ),

      // Estatus CCO - Autorizado / Rechazado
      _buildStatusCell(
        data['autorizado']?.toString() ?? 'Autorizado',
        data['autorizado'] == 'Autorizado' ? Colors.green : Colors.red,
        context,
        data['IdTren']?.toString(),
      ),

      // Fecha Autorizado / Rechazado
      _buildCellDateString(
        text: data['autorizado_por']?.toString() ?? '', 
        widget: formattedDateCell(
          date: data['fecha_autorizado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
          /*textColor:
              data['autorizado'] == 'Autorizado' ? Colors.green : Colors.red,*/
        ),
      ),

      // Autorizado
      /*_buildCell(
        data['autorizado'] == 'Rechazado'
            ? ''
            : data['llamado_por']?.toString() ?? '',
        Colors.black, 
      ),*/

      // Fecha Envio de Llamado
      _buildCellDateString(
        text: data['llamado_por']?.toString() ?? '', 
        widget: data['autorizado'] == 'Rechazado'
              ? const SizedBox() // Celda vacía si está rechazado
              : formattedDateCell(
                  date: data['fecha_llamado']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
      ),

      // Fecha Llamado
      DataCell(
        Center(
          child: data['autorizado'] == 'Rechazado'
              ? const SizedBox()
              : formattedDateCell(
                  date: data['fecha_llamado']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
        ),
      ),

      //Registro de salida
      DataCell(
        formattedDateCell(
          date: '',
          format: 'dd/MM/yyyy \n HH:mm:ss',
        ),
      ),
    ];
  }

  DataCell _buildValidatedCell(
      String text, String autorizado, String ofrecidoPor) {
    Color textColor;

    if (text == "Sin Errores") {
      textColor = Colors.green;
    } else if (text == "Error de formación") {
      textColor = Colors.red;
    } else {
      textColor = Colors.black;
    }

    return DataCell(
      GestureDetector(
        onTap: (text == "Sin Errores" &&
                autorizado != "Autorizado" &&
                autorizado != "Rechazado")
            ? () {
                if (ofrecidoPor.isEmpty) {
                  _showConfirmationDialog(
                      context); // Muestra el modal si ofrecidoPor está vacío
                }
              }
            : null, // Si está autorizado o rechazado, no hay acción
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  DataCell _buildCell(String text, Color textColor) {
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

  DataCell _buildCellDateString({
    required String text,
    required Widget widget,
    Color textColor = Colors.black,
  }) {
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
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  DataCell _buildCellDateStringObservationsOffered({
    required String messageObservations,
    required String text,
    required Widget widget,
    Color textColor = Colors.blueAccent,
    required String id,
    required BuildContext context,

  }) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget,
            MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Observaciones"),
                      content: Text(
                        messageObservations.isEmpty
                            ? 'Sin Observaciones'
                            : messageObservations,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent,
                    decorationThickness: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildCellDateStringObservations({
    required String messageObservations,
    required String text,
    required Widget widget,
    Color textColor = Colors.blueAccent,
    required String id,
    required BuildContext context,

  }) {
    return DataCell(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget,
            MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Observaciones"),
                      content: Text(
                        messageObservations.isEmpty
                            ? 'Sin Observaciones'
                            : messageObservations,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cerrar"),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent,
                    decorationThickness: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  DataCell _buildStatusCell(
      String text, Color textColor, BuildContext context, [String? IdTren]) {
    final trenProvider = Provider.of<TrainModel>(context, listen: false);
    final tablesProvider =
        Provider.of<TablesTrainsProvider>(context, listen: false);
    //final String tren = trenProvider.selectedTrain ?? '';

    return DataCell(
      MouseRegion(
        cursor: text == 'Rechazado'
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: () async {
            if (text == 'Rechazado' && IdTren != null) {
              await tablesProvider.fetchRechazoInfo(IdTren);
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => const MostrarRechazoObsTrenes(),
                );
              }
            }
          },
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: textColor,
                decoration: text == 'Rechazado'
                    ? TextDecoration.underline
                    : null,
                decorationColor: text == 'Rechazado'? Colors.red : null, // Opcional: subrayado
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          style: _styleText(),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  BoxDecoration _cabeceraTabla() {
    return BoxDecoration(
      border: Border(
        left: BorderSide(color: Colors.grey.shade400),
        right: BorderSide(color: Colors.grey.shade400),
        top: BorderSide(color: Colors.grey.shade400),
        bottom: BorderSide(color: Colors.grey.shade400),
      ),
      color: Colors.black,
    );
  }

  TextStyle _styleText() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 15.0,
      fontWeight: FontWeight.bold,
    );
  }

  // METODO PARA MOSTRAR EL MODAL PARA ENVIAR OFRECIMIENTO
  void _showConfirmationDialog(BuildContext context) {
    final TextEditingController _observacionesController = TextEditingController();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // Se usa un contexto diferente
        return Builder(
          builder: (BuildContext innerContext) {
            // Contexto correcto
            return AlertDialog(
              title: const Center(
                child: Text(
                  'Detalles de la validación del tren',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              content: const SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: Text(
                        'El tren ha sido validado sin errores',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 25.0),
                    Center(
                      child: Text(
                        '¿Deseas enviar el ofrecimiento?',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade200,
                          ),
                          onPressed: () {
                            Navigator.pop(innerContext);
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 30.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade200,
                          ),
                          onPressed: () async {
                            try {
                              final userProvider = Provider.of<UserProvider>(
                                  innerContext,
                                  listen: false);
                              final user = userProvider.userName;

                              final trenProvider = Provider.of<TrainModel>(
                                  context,
                                  listen: false);
                              final tren = trenProvider.selectedTrain;

                              final estacionProvider =
                                  Provider.of<EstacionesProvider>(context,
                                      listen: false);
                              final estacion =
                                  estacionProvider.selectedEstacion;

                              String fechaOfrecido =
                                  DateFormat("yyyy-MM-ddTHH:mm:ss")
                                      .format(DateTime.now());

                              await Provider.of<OfrecimientoTrenProvider>(
                                      innerContext,
                                      listen: false)
                                  .ofrecimientoTren(
                                context: innerContext,
                                tren: tren!,
                                ofrecido: 'OK',
                                ofrecidoPor: user!,
                                fechaOfrecido: fechaOfrecido,
                                estacion: estacion!,
                                observaciones: _observacionesController.text,
                              );

                              Navigator.pop(innerContext);
                              _refreshTable(innerContext);
                              Provider.of<RechazosProvider>(context,
                                      listen: false)
                                  .refreshRechazos(context, user);
                            } catch (error) {
                              Navigator.pop(innerContext);
                              showDialog(
                                context: innerContext,
                                builder: (BuildContext errorContext) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content: Text(
                                        'Hubo un problema al actualizar el ofrecimiento: $error'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(errorContext),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            print('Ofrecimiento enviado');
                          },
                          child: const Text(
                            'Enviar el ofrecimiento',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
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
}
