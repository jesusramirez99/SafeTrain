import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';

import 'package:safe_train/modelos/distritos_provider.dart';

class MdlVerDistritos extends StatefulWidget {
  const MdlVerDistritos({Key? key}) : super(key: key);

  @override
  State<MdlVerDistritos> createState() => MdlVerDistritosState();
}

class MdlVerDistritosState extends State<MdlVerDistritos> {
  late DatosDistritos datosDistritos;
  final int _rowsPerPage = 5;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> mdlTablaDistritos(BuildContext context) async {
    final distritosProvider =
        Provider.of<ShowDistrictsProvider>(context, listen: false);
    await distritosProvider.fetchDistricts();

    datosDistritos = DatosDistritos(distritosProvider.distritos);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                // Usa Consumer para escuchar cambios en el ShowCarsTenderProvider
                return Consumer<ShowDistrictsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Asegúrate de que los datos actualizados se reflejen aquí
                    datosDistritos = DatosDistritos(provider.distritos);

                    return Container(
                      width: 810.0,
                      height: 510.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 810.0,
                            height: 530.0,
                            child: ListView(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      btnSalir(dialogContext),
                                    ],
                                  ),
                                ),
                                PaginatedDataTable(
                                  header: Center(
                                    child: Text(
                                      'Distritos',
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  headingRowColor:
                                      MaterialStateProperty.all(Colors.black),
                                  rowsPerPage: _rowsPerPage,
                                  showFirstLastButtons: true,
                                  onRowsPerPageChanged: null,
                                  columns: _buildColumns(),
                                  source: datosDistritos,
                                  dataRowHeight: 50.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(label: _buildHeaderCell('Distrito')),
      DataColumn(label: _buildHeaderCell('Limite de Peso Bruto')),
      DataColumn(label: _buildHeaderCell('División')),
    ];
  }

  Widget _buildHeaderCell(String text) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: _estiloTexto(),
        ),
      ),
    );
  }

  // ESTILO DEL TEXTO DEL ENCABEZADO DE LAS COLUMNAS
  TextStyle _estiloTexto() {
    return const TextStyle(
      fontSize: 13.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  // BOTON SALIR
  ElevatedButton btnSalir(BuildContext dialogContext) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(dialogContext);
        print('Salir');
      },
      style: estiloBoton(),
      child: Text(
        'Salir',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // ESTILO DE LOS BOTONES
  ButtonStyle estiloBoton() {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.grey.shade400),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      ),
    );
  }

  void _showFlushbar(
      BuildContext context, String message, Color backgroundColor) {
    Flushbar(
      duration: Duration(seconds: 4),
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

class DatosDistritos extends DataTableSource {
  final List<Map<String, dynamic>> distritos;

  DatosDistritos(this.distritos);

  final Set<int> _selectedRows = {};

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= distritos.length) return null!;
    final row = distritos[index];
    return DataRow.byIndex(
      index: index,
      selected: _selectedRows.contains(index),
      onSelectChanged: (bool? selected) {
        if (selected == true) {
          _selectedRows.add(index);
          //_selectedRows.map((index) => _data[index]).toList();
        } else {
          _selectedRows.remove(index);
        }
        print(
            "Filas seleccionadas: $_selectedRows"); // Añade esta línea para depuración
        notifyListeners();
      },
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          // Alternar color de las filas
          if (index % 2 == 0) {
            return Colors.grey.shade200; // Color para filas pares
          } else {
            return Colors.white; // Color para filas impares
          }
        },
      ),
      cells: [
        DataCell(Center(
            child: Text(
          _truncateText(row['distrito'].toString()),
          style: _estiloTextoCells(),
        ))),
        DataCell(Center(
            child: Text(
          _truncateText(row['limitePb'].toString()),
          style: _estiloTextoCells(),
        ))),
        DataCell(Center(
            child: Text(
          _truncateText(row['division'].toString()),
          style: _estiloTextoCells(),
        ))),
      ],
    );
  }

  TextStyle _estiloTextoCells() {
    return const TextStyle(
      fontSize: 12.0,
      color: Colors.black,
    );
  }

  String _truncateText(String text, {int maxLength = 40}) {
    return text.length > maxLength
        ? text.substring(0, maxLength) + '...'
        : text;
  }

  @override
  int get rowCount => distritos.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;

  // Métodos para obtener las filas e IDs seleccionadas
  Set<int> getSelectedRowIndices() => _selectedRows;

  List<Map<String, dynamic>> getSelectedRows() =>
      _selectedRows.map((index) => distritos[index]).toList();

  /*List<int> getSelectedIds() =>
      _selectedRows.map((index) => distritos[index]['id'] as int).toList();*/
}
