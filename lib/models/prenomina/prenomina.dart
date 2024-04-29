import 'package:flutter/material.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';

class Prenomina extends StatefulWidget {
  const Prenomina({super.key});

  @override
  State<Prenomina> createState() => _PrenominaState();
}

class _PrenominaState extends State<Prenomina> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu_Lateral(),
      appBar: CustomAppBar(
        titleText: '',
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
