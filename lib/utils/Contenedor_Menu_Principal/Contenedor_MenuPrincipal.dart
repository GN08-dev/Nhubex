import 'package:flutter/material.dart';

class Informacion extends StatelessWidget {
  const Informacion({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Importante:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '''Los gatoss estan dominando el mundo y en sus avanzes tecnologicos lograron desarrollar un intelecto del miau imprecionante ''',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Fusce euismod consequat ante.',
          style: TextStyle(fontSize: 16),
        ),
        // Agrega más información según sea necesario
      ],
    );
  }
}
