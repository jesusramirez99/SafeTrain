import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/user_provider.dart';

class MdlVerUsers extends StatefulWidget {
  const MdlVerUsers({super.key});
  
  @override
  State<MdlVerUsers> createState() => MdlVerDataUsers();
}

class MdlVerDataUsers extends State<MdlVerUsers> {
  final int _rowsPerPage = 5;
  late UsersDataTable usersDataTable;
  final TextEditingController busquedaController =  TextEditingController();
  final GlobalKey<PaginatedDataTableState> _tablaKey = GlobalKey<PaginatedDataTableState>();


  @override
  void initState() {
    super.initState();
   
  }

  @override
  void dispose() {
    busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future<void> mdlTablaUsers(BuildContext context) async { 
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    await usersProvider.mostrarUsers();
    usersDataTable = UsersDataTable(usersProvider.filtradoUsuarios);
    return showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Consumer<UsersProvider>(
                  builder: (context, provider, child) {
                    if(provider.isLoading){
                      return const CircularProgressIndicator();
                    }
                    usersDataTable.actualizarFiltradoUser(provider.filtradoUsuarios);
                    return Container(
                      width: 1300.0,
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
                            width: 1300.0,
                            height: 580.0,
                            child: ListView(
                              children: [
                                searchUser(context),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      btnSalir(dialogContext),
                                      const SizedBox(width: 15.0),
                                    ],
                                  ),
                                ),

                                PaginatedDataTable(
                                  key: _tablaKey,
                                  header: Center(
                                    child: Text(
                                      'Usuarios',
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  headingRowColor: WidgetStatePropertyAll(Colors.black),
                                  rowsPerPage: _rowsPerPage,
                                  onPageChanged: null,
                                  columns: _buildColumns(),   
                                  source: usersDataTable,
                                  dataRowHeight: 50.0,
                                )
                              ],
                            ),
                          ),

                        ),
                      ),

                    );
                  }
                );
              }
            ),
          ) 
        );
      }
    );
  } 

  List<DataColumn> _buildColumns(){
    return [
      DataColumn(label: _buildHeaderCell('Usuario')),
      DataColumn(label: _buildHeaderCell('Nombre')),
      DataColumn(label: _buildHeaderCell('Correo')),
      DataColumn(label: _buildHeaderCell('Rol')),
      DataColumn(label: _buildHeaderCell('Estaciones')),
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

  Widget searchUser(BuildContext context) {
  return TextFormField(
        controller: busquedaController,
        decoration: const InputDecoration(
          hintText: 'Ingrese el usuario o nombre',
          border: OutlineInputBorder(),
        ),
        onChanged: (text) {
          final provider = Provider.of<UsersProvider>(context, listen: false);
          provider.filtrarUser(text);
          usersDataTable.actualizarFiltradoUser(provider.filtradoUsuarios);

          // Manejo de paginación
          if (_tablaKey.currentState != null && text.isNotEmpty) {
              print('pagina actual');
              _tablaKey.currentState!.pageTo(0);
          }
        },
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

}

class UsersDataTable extends DataTableSource {
  List<Map<String, dynamic>> usuarios;
  UsersDataTable(this.usuarios);
  //late List<Map<String, dynamic>> userFiltrado;


  @override
  DataRow? getRow(int index) {
    if(index >= usuarios.length) return null;

    final user = usuarios[index];


    return DataRow(
      cells: [
        DataCell(
          Center(
            child: Text(user['username'] ?? '', textAlign: TextAlign.center),
          )),
        DataCell(
          Center(
            child: Text(user['nombre'] ?? '', textAlign: TextAlign.center),

          )),
        DataCell(
          Center(
            child: Text(user['email'] ?? '', textAlign: TextAlign.center),
          )),
        DataCell(
          Center(
            child: Text(user['role'] ?? '', textAlign: TextAlign.center),
          )),
        DataCell(
          Container(
            width: double.infinity,
            child: Text((user['ESTACIONES'] as List<dynamic>?) ?.map((e) => e['Estacion']).join(', ') ?? '', textAlign: TextAlign.center, softWrap: true, maxLines: null),
          ),
        ),
          
      ],
    );
  }
 
  @override
  bool get isRowCountApproximate => false;
 
  @override
  int get rowCount => usuarios.length;
 
  @override
  int get selectedRowCount => 0;

  void actualizarFiltradoUser(List<Map<String, dynamic>> nuevosDatosFiltrados){
    usuarios = nuevosDatosFiltrados;
    notifyListeners();
  }    
}

