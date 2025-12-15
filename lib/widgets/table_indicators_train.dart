import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/indicadores_tren_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';

class IndicatorTrainTable extends StatefulWidget {
  final String trainInfo;
  final String estacionActual;
  final VoidCallback toggleTableIndicator;

  const IndicatorTrainTable(
      {super.key,
      required this.trainInfo,
      required this.estacionActual,
      required this.toggleTableIndicator});

  @override
  State<IndicatorTrainTable> createState() => _IndicatorTrainTableState();
}

class _IndicatorTrainTableState extends State<IndicatorTrainTable> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trenProvider = Provider.of<TrainModel>(context, listen: false);
      final tren = trenProvider.selectedTrain;
      Provider.of<IndicatorTrainProvider>(context, listen: false)
          .fetchIndicatorTrain(tren!, widget.estacionActual);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IndicatorTrainProvider>(
      builder: (context, indicatorTrainProvider, child) {
        // Verificamos si estamos cargando datos
        if (indicatorTrainProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Obtenemos los datos del proveedor
        List<Map<String, dynamic>> _indicatorTrain =
            indicatorTrainProvider.indicatorTrain;

        return SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.7,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Center(
                  child: Text(
                    'Indicadores del Tren',
                    style: _titleTables(),
                  ),
                ),
              ),
              _buildSegment(_indicatorTrain, 0,
                  ['Terminal', 'Origen', 'Destino', 'Cargados', 'Vacios']),
              _buildSegment(_indicatorTrain, 1,
                  ['Total Carros', 'Total Carros Minimo', '% Carros']),
              _buildSegment(_indicatorTrain, 2,
                  ['Total Toneladas', 'Tonelaje Minimo', '% Tonelaje']),
              _buildSegment(_indicatorTrain, 3,
                  ['Total Longitud', 'Longitud Minima', '% Longitud']),
              _buildSegment(_indicatorTrain, 4,
                  ['Capacidad Locomotoras', 'Factor HP', 'Tonelaje']),
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Center(
                  child: Text(
                    'Totales de Tren',
                    style: _titleTables(),
                  ),
                ),
              ),
              _buildSegment(_indicatorTrain, 0,
              ['Carros Totales', 'Toneladas Totales', 'Longitud Total']),
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Center(
                  child: Text(
                    'Posición de Locomotoras',
                    style: _titleTables(),
                  ),
                ),
              ),
              _buildSegment(_indicatorTrain, 5, [
                'Secuencia Locomotoras',
                'Secuencia Remotas',
                'Ubicación / Rango Frenos de Aire'
              ]),
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.all(13.0),
                child: Center(
                  child: Text(
                    'Loteo de Tren',
                    style: _titleTables(),
                  ),
                ),
              ),
              _buildSegment(_indicatorTrain, 6, [
                'Lotes Programados',
                'Lotes en el Tren\nLocomotoras a AFT',
                'Lotes fuera de programa'
              ]),
            ],
          ),
        );
      },
    );
  }

  TextStyle _titleTables() {
    return TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
      color: Colors.grey.shade500,
    );
  }

  // Mapa que relaciona los nombres de las columnas con las claves del JSON
  final Map<String, String> columnKeyMap = {
    'Terminal': 'terminal',
    'Origen': 'origen',
    'Destino': 'destino',
    'Cargados': 'cargados',
    'Vacios': 'vacios',
    'Total Carros': 'totalCarros',
    'Total Carros Minimo': 'totalCarrosMin',
    '% Carros': 'porcentajeCarros',
    'Total Toneladas': 'totalToneladas',
    'Tonelaje Minimo': 'tonelajeMin',
    '% Toneladas': 'porcentajeTonelaje',
    'Total Longitud': 'longitud',
    'Longitud Minima': 'longitudMin',
    '% Longitud': 'porcentajeLongitud',
    'Capacidad Locomotoras': 'capacidadLocomotoras',
    'Factor HP': 'factorHP',
    'Tonelaje': 'tonelaje',
    'Secuencia Locomotoras': 'secuenciaLoco',
    'Secuencia Remotas': 'secuenciaRemotas',
    'Ubicación / Rango Frenos de Aire': 'ubicacion',
    'Lotes Programados': 'lotesProgramados',
    'Lotes en el Tren\nLocomotoras a AFT': 'lotesTren',
    'Lotes fuera de programa': 'fueraPrograma',
    'Carros Totales' : 'carrosTotales',
    'Carros Cargados' : 'carrosCargados',
    'Carros Vacios' : 'carrosVacios',
    'Toneladas Totales' : 'toneladasTotales',
    'Longitud Total' : 'longitudTotal'
  };

  final List<String> hintHeaders = [
    'Carros Totales',
    'Carros Cargados',
    'Carros Vacios',
    'Toneladas Totales',
    'Longitud Total',
  ];

  final Map<String, String> headerHints = {
    'Carros Totales': 'Carros mas locomotoras',
    'Carros Cargados': 'Carros mas locomotoras',
    'Carros Vacios': 'Carros mas locomotoras',
    'Toneladas Totales': 'Carros mas locomotoras',
    'Longitud Total': 'Carros mas locomotoras',
  };

  Widget _buildSegment(
    List<Map<String, dynamic>> data,
    int segmentIndex,
    List<String> headers,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula el ancho por columna a partir del ancho máximo disponible
        final double columnWidth = constraints.maxWidth / headers.length;

        // Mapea los datos de las filas a una lista de listas de String
        final rows = data.map((item) {
          return headers.map((header) {
            String key = columnKeyMap[header] ?? header;
            return item[key]?.toString() ?? '';
          }).toList();
        }).toList();

        return DataTable(
          columnSpacing: 0,
          dataRowMinHeight: 45.0,
          decoration: _cabeceraTabla(),
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade400, width: 1),
            verticalInside: BorderSide(color: Colors.grey.shade400, width: 1),
          ),

          columns: headers.map((header) {
            final bool needsHint = hintHeaders.contains(header);
            final childWidget = Container(
              width: columnWidth,
              alignment: Alignment.center,
              child: Text(
                header,
                style: _styleText(),
                textAlign: TextAlign.center,
              ),
            );

            return DataColumn(
              label: needsHint
                  ? Tooltip(
                      message: headerHints[header] ?? header,
                      preferBelow: false,
                      child: childWidget,
                    )
                  : childWidget,
            );
          }).toList(),

          rows: rows.asMap().entries.map((entry) {
            int rowIndex = entry.key;
            List<String> rowData = entry.value;

            return DataRow(

              cells: rowData.asMap().entries.map((cellEntry) {
                int cellIndex = cellEntry.key;
                String cellValue = cellEntry.value;

                String header = headers[cellIndex];
                bool hasHint = headerHints.containsKey(header);

                Widget cellContent = Text(
                  cellValue,
                  style: _cellTextStyle(),
                  textAlign: TextAlign.center,
                );

                if(hasHint){
                  cellContent = Tooltip(
                    message: headerHints[header]!,
                    preferBelow: true,
                    child: cellContent,
                  );
                }

                return DataCell(
                  Container(
                    width: columnWidth,
                    alignment: Alignment.center,
                    child: cellContent,
                  ),
                );
              }).toList(),
              color: WidgetStateColor.resolveWith((states) =>
                  (segmentIndex + rowIndex) % 2 == 0
                      ? Colors.white
                      : Colors.white),
            );
          }).toList(),
        );
      },
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

  TextStyle _cellTextStyle() {
    return const TextStyle(
      color: Colors.black,
      fontSize: 14.0,
    );
  }

  TextStyle _styleText() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 13.0,
      fontWeight: FontWeight.bold,
    );
  }
}
