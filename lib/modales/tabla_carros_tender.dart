import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/cars_tender_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';

class MdlVerCarrosTEnder extends StatefulWidget {
  const MdlVerCarrosTEnder({Key? key}) : super(key: key);

  @override
  State<MdlVerCarrosTEnder> createState() => MdlVerCarrosTEnderState();
}

class MdlVerCarrosTEnderState extends State<MdlVerCarrosTEnder> {
  final int _rowsPerPage = 5;
  late DatosCarrosTender datosCarrosTender;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> mdlTablaTender(BuildContext context) async {
    final carrosTenderProvider =
        Provider.of<TenderProvider>(context, listen: false);
    await carrosTenderProvider.mostrarTender();

    datosCarrosTender = DatosCarrosTender(carrosTenderProvider.carrosTender);

    final ScrollController _scrollController = ScrollController();

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
                return Consumer<TenderProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Asegúrate de que los datos actualizados se reflejen aquí
                    datosCarrosTender =
                        DatosCarrosTender(provider.carrosTender);

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
                            child: Scrollbar(
                              thumbVisibility:
                                  true, // Siempre muestra el scrollbar
                              controller:
                                  _scrollController, // Controlador del scroll
                              thickness:
                                  8.0, // Grosor de la barra de desplazamiento
                              child: ScrollbarTheme(
                                data: ScrollbarThemeData(
                                  thumbColor: MaterialStateProperty.all(Colors
                                      .grey
                                      .shade500), // Color sólido de la barra de desplazamiento
                                  trackColor: MaterialStateProperty.all(Colors
                                      .grey
                                      .shade500), // Color del fondo del track
                                  radius: Radius.circular(
                                      10.0), // Radio para las esquinas redondeadas
                                  thickness: MaterialStateProperty.all(
                                      8.0), // Grosor de la barra de desplazamiento
                                ),
                                child: ListView(
                                  controller:
                                      _scrollController, // Vincula el controlador al ListView
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                          'Carros Tender',
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                      rowsPerPage: _rowsPerPage,
                                      showFirstLastButtons: true,
                                      onRowsPerPageChanged: null,
                                      columns: _buildColumns(),
                                      source: datosCarrosTender,
                                      dataRowHeight: 50.0,
                                    ),
                                  ],
                                ),
                              ),
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
      DataColumn(label: _buildHeaderCell('Carro')),
      DataColumn(label: _buildHeaderCell('Descripción')),
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
  ElevatedButton btnActivo(BuildContext context, TenderProvider provider) {
    final dateTime = DateTime.now().toIso8601String();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;

    return ElevatedButton(
      onPressed: () async {
        Set<int> selectedRowIndices = datosCarrosTender.getSelectedRowIndices();
        print('Índices de filas seleccionadas: $selectedRowIndices');

        List<Map<String, dynamic>> selectedRows =
            datosCarrosTender.getSelectedRows();
        print('Filas seleccionadas: $selectedRows');

        List<int> selectedIds = datosCarrosTender.getSelectedIds();
        print('ID de los carros seleccionados: $selectedIds');

        List<int> selectedStatus = datosCarrosTender.getSelectedStatus();
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
            final carTenderProvider = Provider.of<UpdateToActiveTenderProvider>(
                context,
                listen: false);

            for (int id in selectedIds) {
              await carTenderProvider.updateCarTender(
                  id, userName!, dateTime, 1);
            }

            _showFlushbar(
                context,
                'Estatus de carros actualizados correctamente',
                Colors.green.shade400);

            await Future.delayed(Duration(seconds: 3));

            // Actualiza los datos en el modal anterior
            await provider.mostrarTender();
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
  ElevatedButton btnInactivo(BuildContext context, TenderProvider provider) {
    final dateTime = DateTime.now().toIso8601String();
    final userName = Provider.of<UserProvider>(context, listen: false).userName;

    return ElevatedButton(
      onPressed: () async {
        Set<int> selectedRowIndices = datosCarrosTender.getSelectedRowIndices();
        print('INDICES: $selectedRowIndices');

        List<Map<String, dynamic>> selectedRows =
            datosCarrosTender.getSelectedRows();
        print('Filas seleccionadas: $selectedRows');

        List<int> selectedIds = datosCarrosTender.getSelectedIds();
        print('ID CARRO: $selectedIds');

        List<String> selectedCarros = datosCarrosTender.getSelectedCarros();
        print('carro: $selectedCarros');

        List<int> selectedStatus = datosCarrosTender.getSelectedStatus();
        print('ESTATUS: $selectedStatus');

        if (selectedRows.isEmpty) {
          _showFlushbar(context, 'No hay carros seleccionados', Colors.red);
        } else {
          bool allInactive = selectedStatus.every((status) => status == 2);

          if (allInactive) {
            _showFlushbar(context,
                'Los carros seleccionados ya están inactivos.', Colors.red);
          } else if (selectedIds.isNotEmpty) {
            final carTenderProvider =
                Provider.of<TenderProvider>(context, listen: false);

            for (int id in selectedIds) {
              await carTenderProvider.actualizarTender(
                  id, userName!, dateTime, 2);
            }

            _showFlushbar(
                context,
                'Estatus de carros actualizados correctamente',
                Colors.green.shade400);

            await Future.delayed(Duration(seconds: 2));

            // Actualiza los datos en el modal anterior
            await provider.mostrarTender();
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
        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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

class DatosCarrosTender extends DataTableSource {
  final List<Map<String, dynamic>> carrosTender;

  DatosCarrosTender(this.carrosTender);

  final Set<int> _selectedRows = {};

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= carrosTender.length) return null!;
    final row = carrosTender[index];
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
  int get rowCount => carrosTender.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedRows.length;

  // Métodos para obtener las filas e IDs seleccionadas
  Set<int> getSelectedRowIndices() => _selectedRows;

  List<Map<String, dynamic>> getSelectedRows() =>
      _selectedRows.map((index) => carrosTender[index]).toList();

  List<int> getSelectedIds() =>
      _selectedRows.map((index) => carrosTender[index]['id'] as int).toList();

  List<String> getSelectedCarros() => _selectedRows
      .map((index) => carrosTender[index]['carro'].toString())
      .toList();

  List<int> getSelectedStatus() => _selectedRows.map((index) {
        String statusString = carrosTender[index]['estatus'] as String;
        switch (statusString) {
          case 'Activo':
            return 1;
          case 'Inactivo':
            return 2;
          default:
            return 0; // O puedes lanzar una excepción o manejar el error de otra forma
        }
      }).toList();
}
