import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key});

  @override
  State<ExportDialog> createState() => ExportDialogState();
}

class ExportDialogState extends State<ExportDialog> {
  List<String> listop = <String>['Seleccione una opcion', 'Maquinista', 'Normatividad'];
  String? selectedop = 'Seleccione una opcion';
  final TextEditingController reglasController = TextEditingController();
    final TextEditingController tipoController = TextEditingController();
    final TextEditingController descController = TextEditingController();
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }


  Future<void> mdlExportConsist(BuildContext context) async{
    return showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical:  10.0),
              width: 700.0,
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Carga de consist',
                      style: TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 45.0,
                          width: 45.0,
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
                            value: selectedop,
                            onChanged: (newValue){
                              setState(() {
                                selectedop = newValue;
                              });
                            },
                            items: listop.map<DropdownMenuItem<String>>(
                              (String value){
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left:  12.0),
                                    child: Text(
                                        value,
                                        textAlign: TextAlign.left,
                                        style: value == 'Seleccione una opcion'
                                            ? TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade500,
                                              )
                                            : const TextStyle(
                                                color: Colors.black,
                                              ),
                                      ),
                                  )
                                );
                            }).toList(),
                          ),
                        ),

                        
                        
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: SizedBox(
                          height: 45.0,
                          child: _btnUploadConsist(context),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: Container()),
                  const Divider(),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _btnCancelar(dialogContext),
                      //_btnRegistrar(context),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                ],
              ),
            ),
            
          )
        );
      }
    );
  }

  Widget _btnCancelar(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        Navigator.of(context).pop();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            Colors.grey.shade300), // Color de fondo del botón
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 18.0),
          const SizedBox(width: 5.0),
          Text(
            'Regresar',
            style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }  

  Widget _btnUploadConsist(BuildContext context){
    return ElevatedButton(
      onPressed: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if(result != null){
          final file = result.files.first;
        }
      }, 
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          Colors.grey.shade300
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))
        )
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.upload_file, color: Colors.red.shade400, size: 18.0),
          const SizedBox(width: 5.0),
          Text(
            'Cargar',
            style: TextStyle(fontSize: 15.0, color: Colors.grey.shade700),
          ),
        ],
      )
    );
  }
}
