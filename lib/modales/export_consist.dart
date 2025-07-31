import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/export_consist_provider.dart';

class ExportDialog extends StatefulWidget {
  final ExportConsistProvider provider;
  const ExportDialog({super.key, required this.provider});

  @override
  State<ExportDialog> createState() => ExportDialogState();
}

class ExportDialogState extends State<ExportDialog> {
  List<String> listop = <String>[
    'Selecciona un tipo de prueba',
    'Maquinista',
    'Normatividad',
    'Pruebas'
  ];
  String? _selectedop = 'Selecciona un tipo de prueba';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            width: 700.0,
            height: 250.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Carga de Consist',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: SizedBox(
                            height: 45.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 20.0,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16.0,
                                    ),
                                underline: Container(),
                                value: _selectedop,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedop = newValue!;
                                  });
                                },
                                items: listop.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontWeight: value == 'Selecciona un tipo de prueba' ? FontWeight.bold : FontWeight.normal,
                                        color: value == 'Selecciona un tipo de prueba' ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: SizedBox(
                            height: 45.0,
                            child: ElevatedButton.icon(
                                onPressed: () async {
                                  final provider = Provider.of<ExportConsistProvider>(context, listen: false);
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['xls', 'xlsx'],
                                    withData: true,
                                  );
                                  if (result != null && result.files.isNotEmpty) {
                                    final pickedFile = result.files.first;

                                    if (_selectedop == null || _selectedop == 'Selecciona un tipo de prueba') {
                                      if (!context.mounted) return;

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: const Text('Advertencia'),
                                            content: const SizedBox(
                                              width: 300,   // Ajusta el ancho que desees
                                              //height: 150,  // Opcional: altura también si quieres
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  'Debe seleccionar un tipo de prueba',
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  'Aceptar',
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    }


                                    if (pickedFile.bytes == null) {
                                      if(!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Advertencia'),
                                            content: const SizedBox(
                                              width: 300, 
                                              //height: 150,  // Opcional: altura también si quieres
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  'No fue posible leer el archivo',
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  'Aceptar',
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return;
                                    }

                                    final success = await provider.exportConsist(
                                      _selectedop!,
                                      pickedFile.bytes!,
                                      pickedFile.name,
                                    );

                                    if (success) {
                                      if(!context.mounted) return;
                                      showDialog(
                                        context: context, 
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Row(
                                              children: [
                                                Icon(Icons.check_circle, color: Colors.green),
                                                SizedBox(width: 8),
                                                Text('Consist cargado'),
                                              ],
                                            ),
                                           

                                            content: const SizedBox(
                                              width: 300,   // Ajusta el ancho que desees
                                              //height: 150,  // Opcional: altura también si quieres
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  'Consist subido correctamente',
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: const Text(
                                                  'Aceptar',
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        }
                                      );
                                    } else {
                                      if(!context.mounted) return;
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Row(
                                                children: [
                                                  Icon(Icons.error, color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Error'),
                                                ],
                                              ),
                                              content: SizedBox(
                                                width: 300,
                                                child: Text(provider.errorMessage ?? 'Error desconocido'),
                                              ),  
                                              actions: [
                                                TextButton(
                                                  child: const Text(
                                                    'Aceptar',
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                  }
                                },
                                icon: Icon(Icons.upload_file, color: Colors.red.shade400),
                                label: Text(
                                'Seleccionar archivo',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.grey.shade300),
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                                  ),
                                ),
                            ),
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },    
                        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18.0),
                        label: Text('Salir',
                        style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700)),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.grey.shade300), // Color de fondo del botón
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          padding: WidgetStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(horizontal:  60.0, vertical: 12.0),
                          )
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }
}

Future<void> showExportDialog(BuildContext context) async {
  final provider = Provider.of<ExportConsistProvider>(context, listen: false);
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return ExportDialog(provider: provider);
    },
  );
}
