import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/components/contenedores/Incio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar.dart';

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
      drawer: SideMenu(
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
