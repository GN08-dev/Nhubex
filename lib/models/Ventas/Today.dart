import 'package:flutter/material.dart';

class DiaVentas extends StatelessWidget {
  const DiaVentas({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          'No hay datos para mostrar',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
