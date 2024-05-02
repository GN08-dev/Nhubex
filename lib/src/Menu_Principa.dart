import 'package:flutter/material.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/components/contenedores/Incio_Administrador.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class Menu_Principal extends StatefulWidget {
  const Menu_Principal({Key? key}) : super(key: key);

  @override
  State<Menu_Principal> createState() => _Menu_PrincipalState();
}

class _Menu_PrincipalState extends State<Menu_Principal> {
  late String rol = "";

  @override
  void initState() {
    super.initState();
    obtenerRolUsuario(); // Llama a la función para obtener el rol al iniciar el estado del widget
  }

  // Función para obtener el rol del usuario desde SharedPreferences
  void obtenerRolUsuario() async {
    // ignore: unused_local_variable
    SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Menu_Lateral(),
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
                child: const WelcomeInfo(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
