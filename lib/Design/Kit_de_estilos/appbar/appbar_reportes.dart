import 'package:flutter/material.dart';

class AppBarReportes extends AppBar {
  AppBarReportes({super.key, required String titleText})
      : super(
            title: Text(
              titleText,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            backgroundColor: Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            centerTitle: true);

  // Puedes agregar más métodos o propiedades personalizadas si es necesario
}
