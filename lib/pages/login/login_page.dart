import 'package:flutter/material.dart';
import 'package:safe_train/widgets/form_login.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 102, 100, 97),
        body: Stack(
          children: [
            FormLogin(),
          ],
        ),
      ),
    );
  }
}
