import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menus_Inicio_Usuario/Inicio_Usuario.dart';

class Menu_Principal_Usuarios extends StatefulWidget {
  final String companyName;

  const Menu_Principal_Usuarios({super.key, required this.companyName});

  @override
  State<Menu_Principal_Usuarios> createState() =>
      _Menu_Principal_UsuariosState();
}

class _Menu_Principal_UsuariosState extends State<Menu_Principal_Usuarios> {
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
                  child: Incio_Usuario(
                    companyName: widget.companyName,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
