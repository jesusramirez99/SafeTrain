import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
  final String label;
  final List<String> items;
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const CustomDropdownButton({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 40.0,
          height: 40.0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 1.0),
        Expanded(
          child: Container(
            height: 40.0,
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
              value: widget.selectedValue,
              onChanged: widget.onChanged,
              items: widget.items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      value,
                      textAlign: TextAlign.left,
                      style: value == 'Seleccione un Rol' ||
                              value == 'Seleccione una Región' ||
                              value == "Seleccione una División" ||
                              value == "Seleccione una Estación"
                          ? TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade500,
                            )
                          : const TextStyle(
                              color: Colors.black,
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
