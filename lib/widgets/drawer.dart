import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:safe_train/modales/crud_carros_abiertos.dart';
import 'package:safe_train/modales/crud_carros_tender.dart';
import 'package:safe_train/modales/crud_reglas.dart';
import 'package:safe_train/modales/crud_stcc.dart';
import 'package:safe_train/modales/crud_usuarios.dart';
import 'package:safe_train/modales/tabla_carros_abiertos.dart';
import 'package:safe_train/modales/tabla_carros_tender.dart';
import 'package:safe_train/modales/tabla_distritos.dart';
import 'package:safe_train/modales/tabla_stcc.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade100,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                titleDrawerHeader(),
                listElements(),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Salir',
                style: TextStyle(fontSize: 16.0, color: Colors.red)),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  DrawerHeader titleDrawerHeader() {
    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Color.fromARGB(235, 0, 0, 0),
      ),
      child: Center(
        child: Text(
          'Catálogos',
          style: TextStyle(
              color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Opciones Carros Tender
  ExpansionTile opcionesCarrosTender() {
    return ExpansionTile(
      leading: iconList(Icons.directions_railway),
      title: const Text(
        'Carros Tender',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(
          leading: Icon(Icons.view_list, color: Colors.grey.shade700),
          title: Text(
            'Visualizar Carros',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            MdlVerCarrosTEnderState modal = MdlVerCarrosTEnderState();
            modal.mdlTablaTender(context);
            print('tabla tender');
          },
        ),
        ListTile(
          leading: Icon(Icons.add_circle_outline, color: Colors.grey.shade700),
          title: Text(
            'Nuevo',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            CarrosTenderState().mdlCarrosTender(context);
          },
        ),
      ],
    );
  }

  // Opciones carros abiertos
  ExpansionTile opcionesCarrosAbiertos() {
    return ExpansionTile(
      leading: const Icon(Icons.directions_transit_filled_outlined),
      title: const Text(
        'Carros Abiertos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(
          leading: Icon(Icons.view_list, color: Colors.grey.shade700),
          title: Text(
            'Visualizar Carros',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            MdlVerCarrosAbiertosState modal = MdlVerCarrosAbiertosState();
            modal.mdlTablaAbiertos(context);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.add_circle_outline,
            color: Colors.grey.shade700,
          ),
          title: Text(
            'Nuevo',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            CarrosAbiertosState().mdlCarrosAbiertos(context);
          },
        ),
      ],
    );
  }

  // Opciones Trenes Distritos
  ExpansionTile opcionesTrenesDistritos() {
    return ExpansionTile(
      leading: const Icon(Icons.add_location),
      title: const Text(
        'Trenes Distritos',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(
          leading: Icon(Icons.view_list, color: Colors.grey.shade700),
          title: Text(
            'Visualizar Distritos',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            MdlVerDistritosState mdlDistritos = MdlVerDistritosState();
            mdlDistritos.mdlTablaDistritos(context);
          },
        ),
      ],
    );
  }

  // Opciones Reglas
  ExpansionTile opcionesReglas() {
    return ExpansionTile(
      leading: const Icon(Icons.article),
      title: const Text(
        'Reglas',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(
          leading: Icon(Icons.view_list, color: Colors.grey.shade700),
          title: Text(
            'Visualizar Reglas',
            style: _styleTextOpciones(),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.add_circle_outline,
            color: Colors.grey.shade700,
          ),
          title: Text(
            'Nuevo',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            ReglasState().mdlReglas(context);
          },
        ),
      ],
    );
  }

  // Opciones Usuarios
  ExpansionTile opcionesUsuarios() {
    return ExpansionTile(
      leading: const Icon(Icons.accessibility_new),
      title: const Text(
        'Usuarios',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(
          leading: const Icon(Icons.list_alt_outlined),
          title: Text(
            'Lista de Usuarios',
            style: _styleTextOpciones(),
          ),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.add_circle_outline,
            color: Colors.grey.shade700,
          ),
          title: Text(
            'Nuevo',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            UsuariosState().mdlUsuarios(context);
          },
        ),
      ],
    );
  }

  // Opciones STCC
  ExpansionTile opcionesSTCC() {
    return ExpansionTile(
      leading: const Icon(Icons.aod_rounded),
      title: const Text(
        'STCC',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        ListTile(
          leading: Icon(
            Icons.view_list,
            color: Colors.grey.shade700,
          ),
          title: Text('Visualizar STCC', style: _styleTextOpciones()),
          onTap: () {
            MdlVerSTCCState mdlSTCC = MdlVerSTCCState();
            mdlSTCC.mdlTablaSTCC(context);
          },
        ),
        ListTile(
          leading: Icon(
            Icons.add_circle_outline,
            color: Colors.grey.shade700,
          ),
          title: Text(
            'Nuevo',
            style: _styleTextOpciones(),
          ),
          onTap: () {
            STCCState().mdlSTCC(context);
          },
        ),
      ],
    );
  }

  Widget listElements() {
    return Column(
      children: [
        opcionesCarrosTender(),
        const Divider(),
        opcionesCarrosAbiertos(),
        const Divider(),
        opcionesTrenesDistritos(),
        const Divider(),
        opcionesSTCC(),
        const Divider(),
        opcionesReglas(),
        const Divider(),
        opcionesUsuarios(),
        const Divider(),
      ],
    );
  }

  // ESTILOS DE LAS LISTAS

  TextStyle _styleTextOpciones() {
    return TextStyle(
      fontSize: 16.0,
      color: Colors.grey.shade700,
    );
  }

  // Icono de las listas
  Icon iconList(IconData iconData) {
    return Icon(
      iconData,
      color: const Color.fromARGB(255, 66, 66, 66),
      size: 25.0,
    );
  }

  // Icono flecha abajo
  Icon iconArrowDown() {
    return Icon(
      _isExpanded ? Icons.arrow_drop_down : Icons.arrow_right_outlined,
      color: const Color.fromARGB(255, 66, 66, 66),
      size: 25.0,
    );
  }

  // Texto de la lista
  Text textList(String texto) {
    return Text(
      texto,
    );
  }
}
