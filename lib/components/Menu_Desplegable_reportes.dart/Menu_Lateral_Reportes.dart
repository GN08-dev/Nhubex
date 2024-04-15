import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable_reportes.dart/Titulos_reportes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/info_card.dart';

class MenuLateralReportes extends StatefulWidget {
  final Function(String) onTimePeriodSelected;
  //final Function(String) onSucursalSelected;

  const MenuLateralReportes({
    Key? key,
    required this.onTimePeriodSelected,
    //required this.onSucursalSelected,
  }) : super(key: key);

  @override
  _MenuLateralReportesState createState() => _MenuLateralReportesState();
}

class _MenuLateralReportesState extends State<MenuLateralReportes> {
  String nombreUsuario = '';
  String nombreEmpresa = '';
  bool isFechaExpanded = false;
  bool isSucursalExpanded = false;
  List<String> sucursales = [];

  @override
  void initState() {
    super.initState();
    obtenerNombreUsuario();
    obtenerNombreEmpresa();
  }

  // Función para establecer la lista de sucursales
  void setSucursales(List<String> nuevasSucursales) {
    setState(() {
      sucursales = nuevasSucursales;
    });
  }

  // Función para obtener el nombre del usuario
  Future<void> obtenerNombreUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('Nombre') ?? '';
    });
  }

  // Función para obtener el nombre de la empresa
  Future<void> obtenerNombreEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreEmpresa = prefs.getString('nombre_empresa') ?? '';
    });
  }

  // Método para manejar la selección de una opción en el menú
  void handleMenuTap(String title) {
    setState(() {
      if (title == 'Fecha') {
        isFechaExpanded = !isFechaExpanded;
      } else if (title == 'Sucursal') {
        isSucursalExpanded = !isSucursalExpanded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sideMenus = MenuReportes.getSideMenus(); // Menús laterales

    return Drawer(
      child: Column(
        children: [
          Container(
            color: const Color.fromRGBO(0, 184, 239, 1),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  InfoCard(
                    name: nombreUsuario,
                    profession: nombreEmpresa,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: const Color.fromRGBO(46, 48, 53, 1),
              child: ListView.builder(
                itemCount: sideMenus.length,
                itemBuilder: (context, index) {
                  final item = sideMenus[index];

                  // Manejo de la expansión y contracción de "Fecha" y "Sucursal"
                  if (item['title'] == 'Fecha') {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => handleMenuTap(item['title']),
                          child: ListTile(
                            title: Text(
                              item['title'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Icon(
                              isFechaExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isFechaExpanded)
                          ...buildFechaOptions(), // Muestra las opciones de "Fecha"
                      ],
                    );
                  } else if (item['title'] == 'Sucursal') {
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () => handleMenuTap(item['title']),
                          child: ListTile(
                            title: Text(
                              item['title'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: Icon(
                              isSucursalExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isSucursalExpanded)
                          ...buildSucursalOptions(), // Muestra las opciones de "Sucursal"
                      ],
                    );
                  } else {
                    return ListTile(
                      title: Text(
                        item['title'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        // Puedes agregar la funcionalidad adicional aquí para otros elementos del menú
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Función para construir las opciones de "Fecha"
  List<Widget> buildFechaOptions() {
    final sideSeleccion = Seleccion.getsideSeleccion(); // Opciones de selección

    return sideSeleccion.map((item) {
      return GestureDetector(
        onTap: () {
          widget.onTimePeriodSelected(item['title']);
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black26,
          child: ListTile(
            title: Text(
              item['title'],
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }).toList();
  }

  // Función para construir las opciones de "Sucursal"
  List<Widget> buildSucursalOptions() {
    return sucursales.map((sucursal) {
      return GestureDetector(
        onTap: () {
          // widget.onSucursalSelected(sucursal);
          Navigator.pop(context); // Cierra el drawer
        },
        child: Container(
          color: Colors.black26, // Fondo oscuro para las opciones
          child: ListTile(
            title: Text(
              sucursal,
              style: const TextStyle(color: Colors.white), // Texto en blanco
            ),
          ),
        ),
      );
    }).toList();
  }
}
