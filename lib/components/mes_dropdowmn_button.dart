import 'package:flutter/material.dart';

class MesDropdownButton extends StatelessWidget {
  final Map<String, String> meses;
  final String selectedMes;
  final ValueChanged<String>? onChanged;

  const MesDropdownButton({
    super.key,
    required this.meses,
    required this.selectedMes,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedMes,
      onChanged: onChanged != null
          ? (String? newValue) {
              // Verifica si onChanged no es nulo
              if (newValue != null && onChanged != null) {
                onChanged!(
                    newValue); // Llama a la función onChanged pasando newValue
              }
            }
          : null, // Si onChanged es nulo, asigna null al onChanged del DropdownButton
      items: meses.keys.map<DropdownMenuItem<String>>((String key) {
        return DropdownMenuItem<String>(
          value: meses[key],
          child: Text(key),
        );
      }).toList(),
    );
  }
}
