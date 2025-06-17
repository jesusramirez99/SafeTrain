import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/cars_open_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';

class MdlVerCarrosAbiertos extends StatefulWidget {
  const MdlVerCarrosAbiertos({super.key});

  @override
  State<MdlVerCarrosAbiertos> createState() => MdlVerCarrosAbiertosState();
}

class MdlVerCarrosAbiertosState extends State<MdlVerCarrosAbiertos> {
  late DatosCarrosAbiertos datosCarrosAbiertos;
  final int _rowsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> mdlTablaAbiertos(BuildContext context) async {
    final carrosAbiertosProvider =
        Provider.of<CarsOpenProvider>(context, listen: false);
    await carrosAbiertosProvider.mostrarCarrosAbiertos();

    datosCarrosAbiertos =
        DatosCarrosAbiertos(carrosAbiertosProvider.carrosAbiertos);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Consumer<CarsOpenProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Asegúrate de que los datos actualizados se reflejen aquí
                    datosCarrosAbiertos =
                        DatosCarrosAbiertos(provider.carrosAbiertos);

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
                                      btnActivo(context, provider),
                                      const SizedBox(width: 15.0),
                                      btnInactivo(context, provider),
                                      const SizedBox(width: 15.0),
                                      btnSalir(dialogContext),
                                    ],
                                  ),
                                ),
                                PaginatedDataTable(
                                  header: Center(
                                    child: Text(
                                      'Carros Abiertos',
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
                                  source: datosCarrosAbiertos,
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
      DataColumn(label: _buildHeaderCell('Tipo de Carro')),
      DataColumn(label: _buildHeaderCell('Descripción de Carro')),
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
  ElevatedButton btnActivo(BuildContext context, CarsOpenProvider provider) {
    final dateTime = DateTime.now().toIso8601String();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;

    return ElevatedButton(
      onPressed: () async {
        Set<int> selectedRowIndices =
            datosCarrosAbiertos.getSelectedRowIndices();
        print('Índices de filas seleccionadas: $selectedRowIndices');

        List<Map<String, dynamic>> selectedRows =
            datosCarrosAbiertos.getSelectedRows();
        print('Filas seleccionadas: $selectedRows');

        List<int> selectedIds = datosCarrosAbiertos.getSelectedIds();
        print('ID de los carros seleccionados: $selectedIds');

        List<int> selectedStatus = datosCarrosAbiertos.getSelectedStatus();
        print('Estatus de los carros seleccionados: $selectedStatus');

        if (selectedRows.isEmpty) {
          _showFlushbar(context, 'No hay carros seleccionados', Colors.red);
        } else {
          // Verificar si todos los carros seleccionados ya están inactivos
          bool allInactive = selectedStatus.every((status) => status == 1);

          if (allInactive) {
            // Mostrar mensaje si todos los carros ya están inactivos
            _showFlushbar(context, 'Los carros seleccionados ya están Activos.',
                Colors.red);
          } else if (selectedIds.isNotEmpty) {
            // Usa el Provider para actualizar el estado del carro
            final carOpenProvider =
                Provider.of<CarsOpenProvider>(context, listen: false);

            for (int id in selectedIds) {
              await carOpenProvider.estatusCarrosAbiertos(id, userName!,
                  dateTime, 1); // Asumiendo que el nuevo estado es 2
            }

            _showFlushbar(
                context,
                'Estatus de carros actualizados correctamente',
                Colors.green.shade400);

            await Future.delayed(Duration(seconds: 2));

            // Cierra el modal actual
            Navigator.of(context).pop();

            // Espera un momento para asegurarse de que el modal se haya cerrado
            await Future.delayed(Duration(milliseconds: 500));

            // Actualiza los datos en el modal anterior
            await provider.mostrarCarrosAbiertos();
          } else {
            _showFlushbar(
                context, 'Error en la actualización de estatus', Colors.red);
          }
        }
      },
      style: estiloBoton(),
      child: const Text(
        'Activo',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // BOTON INACTIVO
  ElevatedButton btnInactivo(BuildContext context, CarsOpenProvider provider) {
    final dateTime = DateTime.now().toIso8601String();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;

    return ElevatedButton(
      onPressed: () async {
        Set<int> selectedRowIndices =
            datosCarrosAbiertos.getSelectedRowIndices();
        print('INDICES: $selectedRowIndices');

        List<Map<String, dynamic>> selectedRows =
            datosCarrosAbiertos.getSelectedRows();
        print('Filas seleccionadas: $selectedRows');

        List<int> selectedIds = datosCarrosAbiertos.getSelectedIds();
        print('ID CARRO: $selectedIds');

        List<int> selectedStatus = datosCarrosAbiertos.getSelectedStatus();
        print('ESTATUS: $selectedStatus');

        if (selectedRows.isEmpty) {
          _showFlushbar(context, 'No hay carros seleccionados', Colors.red);
        } else {
          bool allInactive = selectedStatus.every((status) => status == 2);

          if (allInactive) {
            _showFlushbar(context,
                'Los carros seleccionados ya están inactivos.', Colors.red);
          } else if (selectedIds.isNotEmpty) {
            final carOpenProvider =
                Provider.of<CarsOpenProvider>(context, listen: false);

            for (int id in selectedIds) {
              await carOpenProvider.estatusCarrosAbiertos(
                  id, userName!, dateTime, 0);
            }

            _showFlushbar(
                context,
                'Estatus de carros actualizados correctamente',
                Colors.green.shade400);

            await Future.delayed(Duration(seconds: 2));

            // Cierra el modal actual
            Navigator.of(context).pop();

            // Espera un momento para asegurarse de que el modal se haya cerrado
            await Future.delayed(Duration(milliseconds: 500));

            // Actualiza los datos en el modal anterior
            await provider.mostrarCarrosAbiertos();
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

class DatosCarrosAbiertos extends DataTableSource {
  final List<Map<String, dynamic>> carrosAbiertos;

  DatosCarrosAbiertos(this.carrosAbiertos);

  final Set<int> _selectedRows = {};

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= carrosAbiertos.length) return null!;
    final row = carrosAbiertos[index];
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
        print("Filas seleccionadas: $_selectedRows");
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
          _truncateText(row['carro'].toString()),
          style: _estiloTextoCells(),
        ))),
        DataCell(Center(
            child: Text(
          _truncateText(row['descripcion'].toString()),
          style: _estiloTextoCells(),
        ))),
        DataCell(Center(
            child: Text(
          _truncateText(row['estatus'].toString()),
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
  int get rowCount => carrosAbiertos.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;

  // Métodos para obtener las filas e IDs seleccionadas
  Set<int> getSelectedRowIndices() => _selectedRows;

  List<Map<String, dynamic>> getSelectedRows() =>
      _selectedRows.map((index) => carrosAbiertos[index]).toList();

  List<int> getSelectedIds() =>
      _selectedRows.map((index) => carrosAbiertos[index]['id'] as int).toList();

  List<int> getSelectedStatus() => _selectedRows.map((index) {
        String statusString = carrosAbiertos[index]['estatus'] as String;
        switch (statusString) {
          case 'Activo':
            return 1;
          case 'Inactivo':
            return 2;
          default:
            return 0;
        }
      }).toList();
}
