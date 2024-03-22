import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/models/EmpresaImageHelper.dart';
import 'package:flutter_proyect/utils/Contenedor/Informacion_Contenedor_MENUl.dart';

class MainMenu extends StatefulWidget {
  final String companyName; // Campo para almacenar el nombre de la empresa

  const MainMenu({super.key, required this.companyName});

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
        title: Text(
          widget.companyName, // Usar el nombre de la empresa proporcionado
          style: const TextStyle(color: Colors.black),
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
                child: const Informacion(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
