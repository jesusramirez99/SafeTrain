import 'package:flutter/material.dart';
import 'package:safe_train/widgets/dropdown_select_fc.dart';

class SelectFFCC extends StatefulWidget {
  const SelectFFCC({super.key});

  @override
  State<SelectFFCC> createState() => _SelectFFCCState();
}

class _SelectFFCCState extends State<SelectFFCC> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 102, 100, 97),
      body: Stack(
        children: [
          DropdownFC(),
        ],
      ),
    );
  }
}
