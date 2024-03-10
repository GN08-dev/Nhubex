import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/utils/Contenedor_Menu_Principal/Contenedor_MenuPrincipal.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const SideMenu(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(179, 47, 98, 207),
        title: const Text(
          'Inicio',
          style: TextStyle(color: Colors.black),
        ),
      ),
      //cuerpo
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            // borderRadius: BorderRadius.circular(10),
          ),
          child: const Informacion(),
        ),
      ),
    );
  }
}
