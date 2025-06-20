import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/reglas_incumplidas_tren.dart';
import 'package:safe_train/modelos/reglas_incumplidas_tren_modelo.dart';
import 'package:safe_train/modelos/validacion_reglas_provider.dart';

class ModalCarrosReglasIncumplidas extends StatefulWidget {
  const ModalCarrosReglasIncumplidas({super.key});

  @override
  _ModalCarrosReglasIncumplidasState createState() =>
      _ModalCarrosReglasIncumplidasState();
}

class _ModalCarrosReglasIncumplidasState
    extends State<ModalCarrosReglasIncumplidas> {
  // Offset inicial
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {

    final validacionProvider = Provider.of<ValidacionReglasProvider>(context, listen: false);
    final reglasProvider = Provider.of<ReglasIncumplidasTrenProvider>(context);
    return Transform.translate(
      offset: offset,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          setState(() {
            offset += details.delta;
          });
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.5,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón para cerrar el modal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                        iconSize: 24.0,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Center(
                    child: Text(
                      'Error de formación',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(
                    thickness: 1,
                  ),
                  const SizedBox(height: 10.0),

                  reglasProvider.reglasIncumplidas.isNotEmpty
                  ? Consumer<ReglasIncumplidasTrenProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        Map<String, List<ReglasIncumplidasTren>> reglasAgrupadas =
                            _agruparPorReglas(provider.reglasIncumplidas);

                        return Column(
                          children: reglasAgrupadas.keys.map((regla) {
                            var reglas = reglasAgrupadas[regla]!;

                            String descripcion = reglas.isNotEmpty
                                ? reglas[0].descripcion
                                : 'Mensaje no disponible';

                            return Column(
                              children: [
                                buildSegment(
                                  context,
                                  title: regla,
                                  descripcion: descripcion,
                                  data: reglas
                                      .map((r) => [
                                            r.sec.toString(),
                                            r.carro,
                                            r.descripcion,
                                          ])
                                      .toList(),
                                ),
                                const SizedBox(height: 23.0),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    )
                  : 
                  const SizedBox(height: 50.0),
                  Center(
                      child: Text(
                        validacionProvider.resultadoMensaje ?? 'No se encontraron reglas incumplidas.',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold, // <- CORRECTO
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                 /* Consumer<ReglasIncumplidasTrenProvider>(
                    builder: (context, provider, child) {
                      // Indicador de carga mientras se obtienen datos
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Agrupar los carros por las reglas incumplidas
                      Map<String, List<ReglasIncumplidasTren>> reglasAgrupadas =
                          _agruparPorReglas(provider.reglasIncumplidas);

                      return Column(
                        children: reglasAgrupadas.keys.map((regla) {
                          var reglas = reglasAgrupadas[regla]!;

                          String descripcion = reglas.isNotEmpty? reglas[0].descripcion : validacionProvider.resultadoMensaje;
                          //print('descripcion de errores:'+descripcion);
                          return Column(
                            children: [
                              buildSegment(
                                context,
                                title: regla,
                                descripcion: descripcion,
                                data: reglas
                                    .map((r) => [
                                          r.sec.toString(),
                                          r.carro,
                                          r.descripcion,
                                        ])
                                    .toList(),
                              ),
                              const SizedBox(height: 23.0),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),*/

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<ReglasIncumplidasTren>> _agruparPorReglas(
      List<ReglasIncumplidasTren> reglasIncumplidas) {
    Map<String, List<ReglasIncumplidasTren>> reglasAgrupadas = {};

    for (var regla in reglasIncumplidas) {
      if (!reglasAgrupadas.containsKey(regla.regla)) {
        reglasAgrupadas[regla.regla] = [];
      }
      reglasAgrupadas[regla.regla]!.add(regla);
    }

    return reglasAgrupadas;
  }

  // Construye la tabla para mostrar los datos
  Widget buildSegment(BuildContext context,
      {required String title,
      required String descripcion,
      required List<List<String>> data}) {
    bool mostrarDetalle = title == "Regla Código de detenido";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 9),
        if (!mostrarDetalle)
          Center(
            child: Text(
              descripcion,
              style: TextStyle(
                fontSize: 19,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        const SizedBox(height: 9),
        Center(
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade400),
            columnWidths: mostrarDetalle
                ? {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(3),
                  }
                : {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.black),
                children: [
                  _buildHeaderCell(context, 'Secuencia'),
                  _buildHeaderCell(context, 'Equipo'),
                  if (mostrarDetalle) _buildHeaderCell(context, 'Detalle'),
                ],
              ),
              ...data.map((row) {
                return TableRow(
                  children: [
                    _buildCell(row[0]),
                    _buildCell(row[1]),
                    if (mostrarDetalle) _buildCell(row[2]),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
