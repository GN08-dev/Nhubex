import 'package:flutter/material.dart';

class SucursalWidget extends StatefulWidget {
  const SucursalWidget({Key? key}) : super(key: key);

  @override
  _SucursalWidgetState createState() => _SucursalWidgetState();
}

class _SucursalWidgetState extends State<SucursalWidget> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Texto "Sucursal:"
        const Text(
          'Sucursal:',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 8),
        Container(
          width: 150,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey), // Borde
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none, // Elimina el borde interior
              hintText: 'Select', // Texto antes de seleccionar una opción
            ),
            value: _selectedOption,
            onChanged: (value) {
              setState(() {
                _selectedOption = value;
              });
            },
            items: const [
              DropdownMenuItem(
                child: Text('Olmos'),
                value: 'Sucursal olmos',
              ),
              DropdownMenuItem(
                child: Text('Opción 2'),
                value: 'opcion2',
              ),
              DropdownMenuItem(
                child: Text('Opción 3'),
                value: 'opcion3',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
