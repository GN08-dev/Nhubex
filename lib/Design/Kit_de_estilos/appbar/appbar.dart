import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({super.key, required String titleText})
      : super(
            title: Text(
              titleText,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            backgroundColor: Color.fromRGBO(3, 133, 185, 1),
            shadowColor: Colors.transparent,
            elevation: 0,
            centerTitle: true);

  // Puedes agregar más métodos o propiedades personalizadas si es necesario
}
