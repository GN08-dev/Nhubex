import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/TitulosDeMenu.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/redireccionamiento.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';

class Menu_Lateral extends StatefulWidget {
  const Menu_Lateral({Key? key}) : super(key: key);

  @override
  State<Menu_Lateral> createState() => _Menu_LateralState();
}

class _Menu_LateralState extends State<Menu_Lateral> {
  Map<String, Color> itemColors = {};
  bool isReportesExpanded = false;
  String empresa = '';
  String nombreUsuario = '';
  String rolUsuario = '';

  @override
  void initState() {
    super.initState();
    obtenerNombreUsuario();
    obtenerRolUsuario();
    obtenerNombreEmpresa(); // Agregar esta línea para obtener el nombre de la empresa
  }

  // Función para obtener el nombre de la empresa
  Future<void> obtenerNombreEmpresa() async {
    String nombreEmpresa = await MenuHelper.obtenerNombreEmpresa();
    setState(() {
      empresa = nombreEmpresa;
    });
  }

  // Función para obtener el nombre del usuario
  Future<void> obtenerNombreUsuario() async {
    String nombre = await MenuHelper.obtenerNombreUsuario();
    setState(() {
      nombreUsuario = nombre;
    });
  }

  // Función para obtener el rol del usuario
  Future<void> obtenerRolUsuario() async {
    String rol = await MenuHelper.obtenerRolUsuario();
    setState(() {
      rolUsuario = rol;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sideMenus = rolUsuario == 'usuario'
        ? MenuDataProviderUsuario.getSideMenusUsuario()
        : MenuDataProvider.getSideMenus();

    return Drawer(
      child: Column(
        children: [
          Container(
            color: Color.fromRGBO(0, 184, 239, 1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  InfoCard(
                    name: nombreUsuario,
                    profession:
                        empresa, // Cambiar 'profession' por el nombre de la empresa
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromRGBO(46, 48, 53, 1),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final item = sideMenus[index];
                  if (item['title'] == 'Informes') {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isReportesExpanded = !isReportesExpanded;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isReportesExpanded
                                  ? Colors.black38
                                  : Colors.transparent,
                            ),
                            child: ListTile(
                              leading: SizedBox(
                                height: 34,
                                width: 34,
                                child: Icon(
                                  item['icon'],
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  color: isReportesExpanded
                                      ? Colors.white
                                      : Colors.white,
                                  fontWeight: isReportesExpanded
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          itemColors[item['title']] = Colors.blue;
                        });
                        MenuHelper.handleButtonTap(context, item);
                        MenuHelper.resetColorAfterDelay(
                            context, item, itemColors);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              itemColors[item['title']] ?? Colors.transparent,
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: ListTile(
                          leading: SizedBox(
                            height: 34,
                            width: 34,
                            child: Icon(
                              item['icon'],
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item['title'],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  }
                },
                itemCount: sideMenus.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
