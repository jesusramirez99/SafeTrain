import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/regla_incumplida_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';
import 'package:table_sticky_headers/table_sticky_headers.dart';
import 'package:safe_train/modelos/tablas_tren_provider.dart';

class InfoTrainTable extends StatefulWidget {
  final String trainInfo;
  final String estacion;
  final VoidCallback toggleTableInfo;

  const InfoTrainTable({
    super.key,
    required this.trainInfo,
    required this.estacion,
    required this.toggleTableInfo,
  });

  @override
  State<InfoTrainTable> createState() => _InfoTrainTableState();
}

class _InfoTrainTableState extends State<InfoTrainTable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<TablesTrainsProvider>(context, listen: false);
      final trenProvider = Provider.of<TrainModel>(context, listen: false);
      final tren = trenProvider.selectedTrain;
      provider.consistTren(context, tren!, widget.estacion);

      Future.delayed(const Duration(seconds: 2), () {
        print("Datos recibidos: ${provider.infoTrain}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TablesTrainsProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return provider.infoTrain.isNotEmpty
        ? SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildStickyTable(provider.infoTrain),
          )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildStickyTable(List<Map<String, dynamic>> infoTrain) {
    final trenProvider = Provider.of<TrainModel>(context, listen: false);
    final tren = trenProvider.selectedTrain;
    List<String> headers = [
      'Secuencia',
      'Unidad',
      'Estatus',
      'Tipo de Equipo',
      'Peso\nBruto',
      'Articulados',
      'Peso\nArticulado',
      'Longitud',
      'Tipo\nLocomotora',
      'Lotear A',
      'Producto',
      'HG',
    ];

    List<List<String>> data = infoTrain.map((item) {
      return [
        item['posicion'].toString(),
        item['unidad'].toString(),
        item['estatus'].toString(),
        item['tipo_equipo'].toString(),
        item['peso'].toString(),
        item['articulados'] == 0 ? '' : item['articulados'].toString(),
        item['pesoArt'] == 0 ? '' : item['pesoArt'].toString(),
        item['longitud'].toString(),
        item['tipo_locomotora']?.toString() ?? '',
        item['lotearA'].toString(),
        item['producto'].toString(),
        item['hg'] == 0 ? '' : item['hg'].toString(),
      ];
    }).toList();

    List<String> reglas =
        infoTrain.map((item) => item['regla'].toString()).toList();

    return Center(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15.0),
            Text(
              'Información del Tren:  $tren',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(
                height: 20.0), // Espaciado entre el título y la tabla
            Expanded(
              child: StickyHeadersTable(
                columnsLength: headers.length,
                rowsLength: data.length,
                columnsTitleBuilder: (i) => _buildHeaderCell(headers[i]),
                rowsTitleBuilder: (i) => _buildRowHeaderCell(
                  '${i + 1}',
                  mostrarIcono: reglas[i].toString().trim() == 'F',
                  item: infoTrain[i],
                ),
                contentCellBuilder: (i, j) =>
                    _buildDataCell(data[j], i, reglas[j], infoTrain[j]),
                legendCell: Container(),
                cellDimensions: CellDimensions.variableColumnWidth(
                  columnWidths: List.generate(headers.length, (index) {
                    double screenWidth = MediaQuery.of(context).size.width;
                    double baseWidth = screenWidth / headers.length;

                    // anchos estaticos para columnas indicadas
                    if (headers[index] == 'Secuencia') {
                      return baseWidth * 0.6;
                    } else if (headers[index] == 'Unidad') {
                      return baseWidth * 0.9;
                    } else if (headers[index] == 'Estatus') {
                      return baseWidth * 0.6;
                    } else if (headers[index] == 'Tipo de Equipo') {
                      return baseWidth * 0.7;
                    } else if (headers[index] == 'Articulados') {
                      return baseWidth * 0.8;
                    } else if (headers[index] == 'Peso\nArticulado') {
                      return baseWidth * 0.7;
                    } else if (headers[index] == 'Peso\nBruto') {
                      return baseWidth * 0.6;
                    } else if (headers[index] == 'Longitud') {
                      return baseWidth * 0.6;
                    } else if (headers[index] == 'HG') {
                      return baseWidth * 0.5;
                    } else {
                      return baseWidth; // Distribución uniforme
                    }
                  }),
                  contentCellHeight: 60,
                  stickyLegendWidth: 0,
                  stickyLegendHeight: 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRowHeaderCell(String text,
      {bool mostrarIcono = false, required Map<String, dynamic> item}) {
    return MouseRegion(
      cursor:
          mostrarIcono ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        child: Container(
          color: mostrarIcono ? Colors.red : Colors.black,
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: mostrarIcono ? Colors.red : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(List<String> rowData, int columnIndex, String regla,
      Map<String, dynamic> item) {
    String text = rowData[columnIndex];
    bool esReglaF = regla == 'F';

    return GestureDetector(
      onTap: () {
        if (esReglaF) {
          _showRuleDetailsModal(context, item);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade500),
            bottom: const BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (esReglaF && columnIndex == 0) // Solo en la columna "Secuencia"
              IconButton(
                icon: const Icon(Icons.warning_rounded, color: Colors.orange),
                tooltip: 'Ver detalles de reglas inválidas',
                onPressed: () {
                  _showRuleDetailsModal(context, item);
                },
              ),
            const SizedBox(height: 6.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 15.0,
                color: esReglaF ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRuleDetailsModal(BuildContext context, Map<String, dynamic> item) {
    final reglaProvider =
        Provider.of<ReglaIncumplidaProvider>(context, listen: false);
    final int idConsist = item['id'] is int
        ? item['id']
        : int.tryParse(item['id'].toString()) ?? 0;

    reglaProvider.mostrarReglaIncumplida(idConsist);

    showDialog(
      context: context,
      builder: (BuildContext context) => _DraggableAlertDialog(
        item: item,
        idConsist: idConsist,
      ),
    );
  }
}

class _DraggableAlertDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final int idConsist;

  const _DraggableAlertDialog({
    Key? key,
    required this.item,
    required this.idConsist,
  }) : super(key: key);

  @override
  __DraggableAlertDialogState createState() => __DraggableAlertDialogState();
}

class __DraggableAlertDialogState extends State<_DraggableAlertDialog> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            offset += details.delta;
          });
        },
        child: AlertDialog(
          title: const Center(
            child: Text(
              'Detalles de la regla incumplida',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Secuencia: ${widget.item['posicion']}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Unidad: ${widget.item['unidad']}',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ReglaIncumplidaProvider>(
                builder: (context, provider, child) {
                  final reglas = provider.reglasIncumplidas
                      .where((regla) => regla.idConsist == widget.idConsist)
                      .toList();

                  if (reglas.isEmpty) {
                    return const Center(
                      child: Text(
                        'No se encontraron reglas incumplidas',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reglas.map((regla) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              regla.regla,
                              style: const TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Center(
                            child: Text(
                              regla.descripcion,
                              style: const TextStyle(fontSize: 18.0),
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, color: Colors.red, size: 22.0),
                  SizedBox(width: 5.0),
                  Text(
                    'Cerrar',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
