import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:safe_train/modelos/itinerario_provider.dart';

class ItinerarioModal {
  static void mostrarModal(BuildContext context, String idTren) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.height * 0.4,
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Itinerario del Tren $idTren',
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12.0),
                Expanded(child: _ItinerarioContent(idTren: idTren)),
                const SizedBox(height: 14.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ItinerarioContent extends StatefulWidget {
  final String idTren;
  const _ItinerarioContent({required this.idTren});

  @override
  _ItinerarioContentState createState() => _ItinerarioContentState();
}

class _ItinerarioContentState extends State<_ItinerarioContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ItinerarioProvider>().mostrarItinerario(widget.idTren);
    });
  }

  String _formatDate(String fecha) {
    try {
      DateTime parsedDate = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<ItinerarioProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.itinerarios.isEmpty) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No hay datos disponibles.')),
          );
        }

        return ListView.builder(
          // 🔹 Aquí agregué `return`
          shrinkWrap: true,
          itemCount: provider.itinerarios.length,
          itemBuilder: (context, index) {
            final itinerario = provider.itinerarios[index];
            return Column(
              children: [
                ListTile(
                  dense: true,
                  title: Text(itinerario['movimiento'],
                      style: const TextStyle(fontSize: 18.0)),
                  subtitle: Text('Estación: ${itinerario['estacion']}',
                      style: const TextStyle(fontSize: 16.0)),
                  trailing: Text(
                    _formatDate(itinerario['fecha']),
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
                if (index < provider.itinerarios.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
