import 'package:flutter/material.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menu_Desplegable/Menu_Lateral.dart';

class Prenomina extends StatefulWidget {
  final String companyName;
  const Prenomina({super.key, required this.companyName});

  @override
  State<Prenomina> createState() => _PrenominaState();
}

class _PrenominaState extends State<Prenomina> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu_Lateral(companyName: widget.companyName),
      appBar: CustomAppBar(
        titleText: widget.companyName,
      ),
      body: Container(
        color: Colors.white, // Color de fondo blanco
        child: const Center(
          child: Text(
            'En desarrollo',
            style: TextStyle(
              fontSize: 24, // Tamaño de fuente del texto
              color: Colors.black, // Color del texto en negro
            ),
          ),
        ),
      ),
    );
  }
}
