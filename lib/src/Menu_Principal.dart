import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/components/ContenedorMain/Incio.dart';
// ignore: unused_import
import 'package:flutter_proyect/models/Contenedor_imagenes/EmpresaImageHelper.dart';

class MainMenu extends StatefulWidget {
  final String companyName;

  const MainMenu({super.key, required this.companyName});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawerScrimColor: Colors.transparent,
      drawer: SideMenu(
        companyName: widget.companyName,
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text(
          'Inicio',
          style: TextStyle(color: Colors.black),
        ),
      ),
      // Cuerpo
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: const InicioInfo()),
            )
          ],
        ),
      ),
    );
  }
}
