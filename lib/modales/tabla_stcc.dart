import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/stcc_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';

class MdlVerSTCC extends StatefulWidget {
  const MdlVerSTCC({super.key});

  @override
  State<MdlVerSTCC> createState() => MdlVerSTCCState();
}

class MdlVerSTCCState extends State<MdlVerSTCC> {
  late DatosSTCC datosSTCC;
  final int _rowsPerPage = 5;
  final TextEditingController busquedaController = TextEditingController();

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Construyendo widget con el botón Inactivo");
    return Container();
  }

  Future<void> mdlTablaSTCC(BuildContext context) async {
    final stccProvider = Provider.of<STCCProvider>(context, listen: false);
    await stccProvider.mostrarSTCC();

    datosSTCC = DatosSTCC(stccProvider.stccFiltrado); // Cambiar a stccFiltrado

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Consumer<STCCProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Actualizar datos en base a la búsqueda filtrada
                    datosSTCC = DatosSTCC(provider.stccFiltrado);

                    return Container(
                      width: 1000.0,
                      height: 550.0,
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
                            width: 990.0,
                            height: 540.0,
                            child: ListView(
                              children: [
                                searchSTCC(context),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      btnActivo(context, provider),
                                      const SizedBox(width: 15.0),
                                      btnInactivo(context, provider),
                                      const SizedBox(width: 15.0),
                                      btnCancelar(context, provider),
                                      const SizedBox(width: 15.0),
                                      btnSalir(dialogContext),
                                      const SizedBox(width: 15.0),

                                      //searchSTCC(),
                                    ],
                                  ),
                                ),
                                PaginatedDataTable(
                                  header: Center(
                                    child: Text(
                                      'STCC',
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
                                  source: datosSTCC,
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
      DataColumn(label: _buildHeaderCell('STCC')),
      DataColumn(label: _buildHeaderCell('Descripción')),
      DataColumn(label: _buildHeaderCell('Clase')),
      DataColumn(label: _buildHeaderCell('Grupo Segregación')),
      DataColumn(label: _buildHeaderCell('Estatus')),
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

  // BOTON ACTIVO
  ElevatedButton btnActivo(BuildContext context, STCCProvider provider) {
    final dateTime = DateTime.now().toIso8601String();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;

    return ElevatedButton(
      onPressed: () async {
        Set<int> selectedRowIndices = datosSTCC.getSelectedRowIndices();
        print('INDICES: $selectedRowIndices');

        List<Map<String, dynamic>> selectedRows = datosSTCC.getSelectedRows();
        print('Filas seleccionadas: $selectedRows');

        List<int> selectedIds = datosSTCC.getSelectedIds();
        print('ID STCC: $selectedIds');

        List<int> selectedStatus = datosSTCC.getSelectedStatus();
        print('ESTATUS: $selectedStatus');

        if (selectedRows.isEmpty) {
          _showFlushbar(context, 'No hay STCC seleccionados', Colors.red);
        } else {
          bool allInactive = selectedStatus.every((status) => status == 1);

          if (allInactive) {
            _showFlushbar(context, 'Los STCC seleccionados ya están activos.',
                Colors.red);
          } else if (selectedIds.isNotEmpty) {
            final stccProvider =
                Provider.of<STCCProvider>(context, listen: false);

            for (int id in selectedIds) {
              await stccProvider.actualizarSTCC(id, 1);
            }

            _showFlushbar(context, 'Estatus de STCC actualizados correctamente',
                Colors.green.shade400);

            await Future.delayed(Duration(seconds: 3));

            // Cierra el modal actual
            //Navigator.of(context).pop();

            // Espera un momento para asegurarse de que el modal se haya cerrado
            //await Future.delayed(Duration(milliseconds: 500));

            // Actualiza los datos en el modal anterior
            //await provider.mostrarSTCC();
            busquedaController.clear();
            await provider.mostrarSTCC();
          } else {
            _showFlushbar(
                context, 'Error en la actualización de estatus', Colors.red);
          }
        }
      },
      style: estiloBoton(),
      child: const Text('Activo', style: TextStyle(color: Colors.white)),
    );
  }

  // BOTON INACTIVO
  ElevatedButton btnInactivo(BuildContext context, STCCProvider provider) {
    final dateTime = DateTime.now().toIso8601String();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;

    return ElevatedButton(
      onPressed: () async {
        print('se presiono el boton inactivo');
        Set<int> selectedRowIndices = datosSTCC.getSelectedRowIndices();
        print('INDICES: $selectedRowIndices');

        List<Map<String, dynamic>> selectedRows = datosSTCC.getSelectedRows();
        print('Filas seleccionadas: $selectedRows');

        List<int> selectedIds = datosSTCC.getSelectedIds();
        print('ID STCC: $selectedIds');

        print(datosSTCC.getSelectedStatus());
        List<int> selectedStatus = datosSTCC.getSelectedStatus();

        if (selectedRows.isEmpty) {
          _showFlushbar(context, 'No hay STCC seleccionados', Colors.red);
        } else {
          bool allInactive = selectedStatus.every((status) => status == 0);

          if (allInactive) {
            _showFlushbar(context, 'Los STCC seleccionados ya están inactivos.',
                Colors.red);
          } else if (selectedIds.isNotEmpty) {
            final stccProvider =
                Provider.of<STCCProvider>(context, listen: false);

            for (int id in selectedIds) {
              await stccProvider.actualizarSTCC(id, 0);
            }

            _showFlushbar(context, 'Estatus de STCC actualizados correctamente',
                Colors.green.shade400);

            await Future.delayed(Duration(seconds: 3));

            busquedaController.clear();
            await provider.mostrarSTCC();
          } else {
            _showFlushbar(
                context, 'Error en la actualización de estatus', Colors.red);
          }
        }
      },
      style: estiloBoton(),
      child: const Text('Inactivo', style: TextStyle(color: Colors.white)),
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
      child: const Text(
        'Salir',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // BOTON CANCELAR
  ElevatedButton btnCancelar(BuildContext context, STCCProvider provider) {
    return ElevatedButton(
        onPressed: () async {
          busquedaController.clear();
          await provider.mostrarSTCC();
        },
        style: estiloBoton(),
        child: const Text(
          'Cancelar',
          style: TextStyle(color: Colors.white),
        ));
  }

  Widget searchSTCC(BuildContext context) {
    return TextFormField(
      controller: busquedaController,
      decoration: const InputDecoration(
        hintText: 'Ingrese STCC o una descripción',
        border: OutlineInputBorder(),
      ),
      onChanged: (text) {
        final provider = Provider.of<STCCProvider>(context, listen: false);

        // Aplica el filtro en el proveedor de datos
        provider.filtrarSTCC(text);

        // Actualiza los datos de la tabla con los resultados filtrados
        datosSTCC.actualizarFiltrado(provider.stccFiltrado);
      },
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

class DatosSTCC extends DataTableSource {
  List<Map<String, dynamic>> stcc;
  final Set<int> _selectedRows = {};
  late List<Map<String, dynamic>> stccFiltrado;

  DatosSTCC(this.stcc) {
    stccFiltrado = List.from(stcc);
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= stcc.length) return null!; // Cambiado a stccFiltrado
    final row = stcc[index]; // Cambiado a stccFiltrado
    return DataRow.byIndex(
      index: index,
      selected: _selectedRows.contains(index),
      onSelectChanged: (bool? selected) {
        if (selected == true) {
          _selectedRows.add(index);
        } else {
          _selectedRows.remove(index);
        }
        print("Filas seleccionadas: $_selectedRows");
        notifyListeners();
      },
      color: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (index % 2 == 0) return Colors.grey.shade200;
          return Colors.white;
        },
      ),
      cells: [
        DataCell(Center(
            child: Text(
          _truncateText(row['STCC'].toString()),
          style: _estiloTextoCells(),
        ))),
        DataCell(Center(
            child: Text(
          _truncateText(row['DESCRIPCION'].toString()),
          style: _estiloTextoCells(),
        ))),
        DataCell(Center(
            child: Text(
          _truncateText(row['CLASE'].toString()),
          style: _estiloTextoCells(),
        ))),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 190),
            child: Center(
              child: Text(
                row['GRUPO_SEGREGACION'].toString(),
                style: _estiloTextoCells(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ),
        ),
        DataCell(
          Center(
            child: Text(
              row['STATUS'] == 1 ? 'Activo' : 'Inactivo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                color: row['STATUS'] == 1 ? Colors.black : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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
  int get rowCount => stcc.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;

  // Métodos para obtener las filas e IDs seleccionadas
  Set<int> getSelectedRowIndices() => _selectedRows;

  List<Map<String, dynamic>> getSelectedRows() =>
      _selectedRows.map((index) => stcc[index]).toList();

  List<int> getSelectedIds() =>
      _selectedRows.map((index) => stcc[index]['ID'] as int).toList();

  List<int> getSelectedStatus() => _selectedRows.map((index) {
        int statusInt = stcc[index]['STATUS'] as int; // Cambiado a int
        switch (statusInt) {
          case 1: // Activo
            return 1;
          case 0: // Inactivo
            return 0;
          default:
            return 3; // Valor predeterminado si no es ni Activo ni Inactivo
        }
      }).toList();

  // Método para actualizar los datos filtrados
  void actualizarFiltrado(List<Map<String, dynamic>> nuevosDatosFiltrados) {
    stccFiltrado = nuevosDatosFiltrados;
    notifyListeners();
  }
}
