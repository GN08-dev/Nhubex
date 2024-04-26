import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_proyect/components/contenedores/Incio_Administrador.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menu_Desplegable/Menu_Lateral.dart';

class Menu_Principal_Administrador extends StatefulWidget {
  final String companyName;

  const Menu_Principal_Administrador({super.key, required this.companyName});

  @override
  State<Menu_Principal_Administrador> createState() => _MainMenuState();
}

class _MainMenuState extends State<Menu_Principal_Administrador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu_Lateral(
        companyName: widget.companyName,
      ),
      appBar: CustomAppBar(titleText: 'Menu Principal'),

      // Cuerpo
      backgroundColor: Colors.white,
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                  ),
                  child: WelcomeInfo(
                    companyName: widget.companyName,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
