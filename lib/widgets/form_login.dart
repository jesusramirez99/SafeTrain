import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_train/modelos/login_provider.dart';
import 'package:safe_train/modelos/user_provider.dart';
import 'package:safe_train/pages/home/home_page.dart';
import 'package:safe_train/pages/ffccpage/select_ffcc_page.dart';

class FormLogin extends StatefulWidget {
  const FormLogin({super.key});

  @override
  State<FormLogin> createState() => _FormLoginState();
}

class _FormLoginState extends State<FormLogin> {
  final GlobalKey<FormState> _formKeyLogin = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _userFocusNode = FocusNode();
  bool textoOculto = true;

  void _login(BuildContext contextPro) async {
    if (_formKeyLogin.currentState!.validate()) {
      String user = _userController.text;
      String password = _passwordController.text;

      final loginProvider =
          Provider.of<LoginProvider>(contextPro, listen: false);

      final loginSuccess = await loginProvider.login(user, password);

      if (loginSuccess) {
        final region = loginProvider.regionPrincipal;

        if (region != null) {
          Provider.of<RegionProvider>(contextPro, listen: false)
              .setRegion(region);
        }

        Navigator.of(contextPro).pushAndRemoveUntil(
          MaterialPageRoute(builder: (contextPro) => const Home()),
          (Route<dynamic> route) => false,
        );
      } else {
        String errorMessage = loginProvider.errorMessage ?? 'Error desconocido';
        Color color = Colors.red;

        if (errorMessage.contains('Connection refused') ||
            errorMessage.contains('SocketException') ||
            errorMessage.contains('Error en el login:')) {
          errorMessage =
              'Error al inciar sesión, intente nuevamente o repórtelo al servicio de soporte de Tren Seguro. Error 500';
          color = Colors.orange;
        }

        _showFlushbar(contextPro, errorMessage, color);
        await Future.delayed(Duration(seconds: 4));
        _userController.clear();
        _passwordController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: const Color.fromRGBO(5, 5, 5, 0.6),
        width: 450.0,
        height: 500.0,
        child: Form(
          key: _formKeyLogin,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15.0),
              Image.asset(
                'assets/images/gmxt-logo.png',
                width: 160,
                height: 70,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20.0),
              Text(
                'Tren Seguro',
                style: estiloTexto(),
              ),
              const SizedBox(height: 25.0),
              _campoUser(),
              const SizedBox(height: 20.0),
              _campoPassword(),
              const SizedBox(height: 25.0),
              _btnLogin(context),
              const SizedBox(height: 15.0),
              _btnRegresar(),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle estiloTexto() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 25.0,
      fontWeight: FontWeight.bold,
    );
  }

  InputDecoration inputDecoration({
    required IconData prefixIcon,
    required String hintText,
    bool isPasswordField = false,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon),
      hintText: hintText,
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      suffixIcon: isPasswordField
          ? IconButton(
              icon: Icon(
                textoOculto ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  textoOculto = !textoOculto;
                });
              },
            )
          : null,
    );
  }

  Widget _campoUser() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 3.0),
      child: TextFormField(
        focusNode: _userFocusNode,
        controller: _userController,
        onChanged: (text) {
          _userController.text = text.toUpperCase();
          _userController.selection = TextSelection.fromPosition(
              TextPosition(offset: _userController.text.length));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingresa tu usuario';
          }
          return null;
        },
        decoration: inputDecoration(
          prefixIcon: Icons.account_circle,
          hintText: 'Usuario',
        ),
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        },
      ),
    );
  }

  // CAMPO PASSWORD
  Widget _campoPassword() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 3.0),
      child: TextFormField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: textoOculto,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, ingrese la contraseña'; // Devuelve un mensaje de error si el campo está vacío
          }
          return null; // Si la contraseña es válida, retorna null
        },
        decoration: inputDecoration(
          prefixIcon: Icons.lock,
          hintText: 'Contraseña',
          isPasswordField: true,
        ),
        textInputAction: TextInputAction.done,
        onFieldSubmitted: (_) {
          if (_formKeyLogin.currentState?.validate() ?? false) {
            // Si la validación es correcta, se llama a la función _login
            String user = _userController.text;
            Provider.of<UserProvider>(context, listen: false).setUserName(user);
            _login(context);
          }
        },
      ),
    );
  }

  // BOTON LOGIN
  Widget _btnLogin(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_formKeyLogin.currentState?.validate() ?? false) {
          String user = _userController.text;

          Provider.of<UserProvider>(context, listen: false).setUserName(user);

          final loginProvider =
              Provider.of<LoginProvider>(context, listen: false);
          final region = loginProvider.regionPrincipal;

          if (region != null) {
            Provider.of<RegionProvider>(context, listen: false)
                .setRegion(region);
          }

          _login(context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(235, 149, 9, 9),
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(5.0),
        child: Text(
          "Ingresar",
          style: TextStyle(
            color: Color.fromARGB(255, 253, 253, 253),
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _btnRegresar() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const SelectFFCC(),
          ),
          (Route<dynamic> route) => false,
        );
      },
      child: const Text(
        'Regresar',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  void _showFlushbar(
      BuildContext context, String message, Color backgroundColor) {
    Flushbar(
      duration: const Duration(seconds: 4),
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
