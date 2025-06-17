import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  int _selectedRowIndex =
      -1; // Inicializa la variable para la fila seleccionada
  String _selectedTrain = '';
  String _selectedEstation = '';

  @override
  Widget build(BuildContext context) {
    final rowSelected = Provider.of<SelectionNotifier>(context);
    final providerDataTrain = Provider.of<TablesTrainsProvider>(context);
    final trainModel = Provider.of<TrainModel>(context, listen: false);
    final estacion = Provider.of<EstacionesProvider>(context, listen: false);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.7,
      child: providerDataTrain.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      'Datos del Tren',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                ),
                DataTable(
                  columnSpacing: 10.0,
                  dataRowHeight: 50.0,
                  decoration: _cabeceraTabla(),
                  columns: _buildColumns(),
                  rows: List<DataRow>.generate(
                    providerDataTrain.dataTrain.length,
                    (index) => DataRow(
                      selected: index == _selectedRowIndex,
                      onSelectChanged: (isSelected) {
                        setState(() {
                          if (isSelected != null && isSelected) {
                            _selectedRowIndex = index;
                            _selectedTrain = providerDataTrain.dataTrain[index]
                                    ['IdTren']
                                .toString();

                            _selectedEstation = providerDataTrain
                                .dataTrain[index]['estacion_actual']
                                .toString();
                            print('Fila seleccionada: $_selectedRowIndex');
                            print('Estacion: $_selectedEstation');
                            print('Tren: $_selectedTrain');

                            trainModel.setSelectedTrain(_selectedTrain);
                            estacion.updateSelectedEstacion(_selectedEstation);

                            rowSelected.updateSelectedRow(index);
                          } else {
                            _selectedRowIndex = -1;
                            _selectedTrain = '';
                            rowSelected.updateSelectedRow(null);
                            print('Fila deseleccionada: $_selectedRowIndex');
                            print('Tren: $_selectedTrain');
                          }
                        });
                      },
                      color: MaterialStateColor.resolveWith(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            // Color cuando está seleccionada
                            return const Color.fromARGB(
                                255, 226, 237, 247); // Azul tenue
                          } else {
                            // Alterna colores de filas
                            return index % 2 == 0 ? Colors.white : Colors.white;
                          }
                        },
                      ),
                      cells: _buildCells(providerDataTrain.dataTrain[index]),
                    ),
                  ),
                  border: TableBorder(
                    horizontalInside:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                    verticalInside:
                        BorderSide(color: Colors.grey.shade400, width: 1),
                  ),
                ),
              ],
            ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(label: _buildHeaderCell('Tren')),
      DataColumn(label: _buildHeaderCell('Estación\nOrigen')),
      DataColumn(label: _buildHeaderCell('Estación\nDestino')),
      DataColumn(label: _buildHeaderCell('Estación\nActual')),
      DataColumn(label: _buildHeaderCell('Total\nCarros')),
      DataColumn(label: _buildHeaderCell('Cargados')),
      DataColumn(label: _buildHeaderCell('Vacíos')),
      DataColumn(label: _buildHeaderCell('Validado')),
      DataColumn(label: _buildHeaderCell('Fecha\nValidado')),
      DataColumn(label: _buildHeaderCell('Ofrecido\npor')),
      DataColumn(label: _buildHeaderCell('Fecha\nOfrecido')),
      DataColumn(label: _buildHeaderCell('Estatus\nCCO')),
      DataColumn(label: _buildHeaderCell('Fecha\nAutorizado / Rechazado')),
      DataColumn(label: _buildHeaderCell('Autorizado')),
      DataColumn(label: _buildHeaderCell('Fecha Envío\n de Llamado')),
      DataColumn(label: _buildHeaderCell('Fecha\nLlamado')),
      DataColumn(label: _buildHeaderCell('Llamada\nCompletada'))
    ];
  }

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
      _buildCell(data['IdTren']?.toString() ?? '', Colors.black),
      _buildCell(data['origen']?.toString() ?? '', Colors.black),
      _buildCell(data['destino']?.toString() ?? '', Colors.black),
      _buildCell(data['estacion_actual']?.toString() ?? '', Colors.black),
      _buildCell(data['carros']?.toString() ?? '', Colors.black),
      _buildCell(data['cargados']?.toString() ?? '', Colors.black),
      _buildCell(data['vacios']?.toString() ?? '', Colors.black),

      // Validado
      _buildValidatedCell(
          data['validado']?.toString() ?? '',
          data['autorizado']?.toString() ?? '',
          data['ofrecido_por']?.toString() ?? ''),

      // Fecha Vaidado
      DataCell(
        formattedDateCell(
          date: data['fecha_validado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
        ),
      ),

      // Ofrecido Por
      _buildCell(data['ofrecido_por']?.toString() ?? '', Colors.black),

      // Fecha Ofrecido

      DataCell(
        Center(
          child: data['ofrecido_por'] == ''
              ? const SizedBox() // Celda vacía si no hay nada en la celda
              : formattedDateCell(
                  date: data['fecha_ofrecido']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
        ),
      ),

      // Estatus CCO - Autorizado / Rechazado
      _buildStatusCell(
        data['autorizado']?.toString() ?? 'Autorizado',
        data['autorizado'] == 'Autorizado' ? Colors.green : Colors.red,
        context,
      ),

      // Fecha Autorizado / Rechazado
      DataCell(
        formattedDateCell(
          date: data['fecha_autorizado']?.toString() ?? '',
          format: 'dd/MM/yyyy \n HH:mm',
          textColor:
              data['autorizado'] == 'Autorizado' ? Colors.green : Colors.red,
        ),
      ),

      // Autorizado
      _buildCell(
        data['autorizado'] == 'Rechazado'
            ? ''
            : data['llamado_por']?.toString() ?? '',
        Colors.black, // Aquí puedes colocar el color que necesites
      ),

      // Fecha Envio de Llamado
      DataCell(
        Center(
          child: data['autorizado'] == 'Rechazado'
              ? const SizedBox() // Celda vacía si está rechazado
              : formattedDateCell(
                  date: data['fecha_autorizado']?.toString() ?? '',
                  format: 'dd/MM/yyyy \n HH:mm',
                ),
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

      // Fecha llamada completada
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
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  DataCell _buildStatusCell(
      String text, Color textColor, BuildContext context) {
    final trenProvider = Provider.of<TrainModel>(context, listen: false);
    final tablesProvider =
        Provider.of<TablesTrainsProvider>(context, listen: false);
    final String tren = trenProvider.selectedTrain ?? '';

    return DataCell(
      MouseRegion(
        cursor: text == 'Rechazado'
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: () async {
            if (text == 'Rechazado') {
              await tablesProvider.fetchRechazoInfo(tren);
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
                    : null, // Opcional: subrayado
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
