import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/TitulosDeMenu.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/info_card.dart';
import 'package:flutter_proyect/router/router.dart';

class SideMenu extends StatefulWidget {
  final String companyName;
  const SideMenu({super.key, required this.companyName});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  Map<String, Color> itemColors = {};

  @override
  Widget build(BuildContext context) {
    final sideMenus = MenuDataProvider.getSideMenus();

    return Drawer(
      child: Column(
        children: [
          Container(
            color: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 25),
                  InfoCard(
                    name: 'Desarrollador',
                    profession: widget.companyName,
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
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        itemColors[item['title']] = Colors.blue;
                      });
                      _handleButtonTap(item);
                      _resetColorAfterDelay(item);
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
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
                },
                itemCount: sideMenus.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonTap(Map<String, dynamic> item) {
    print('Tocaste ${item['title']}');
    if (item['title'] == 'Regresar') {
      Navigator.pop(context);
    } else if (item['title'] == 'Cerrar Sesión') {
      AppRouter.cerrarSesion();
      _navigateDelayed('/login');
    } else if (item['title'] == 'Menú') {
      _navigateDelayed('/menu');
    } else if (item['title'] == 'Reportes') {
      _navigateDelayed('/Reportes');
    }
  }

  void _resetColorAfterDelay(Map<String, dynamic> item) {
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        itemColors[item['title']] = Colors.transparent;
      });
    });
  }

  void _navigateDelayed(String routeName) {
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.pushReplacementNamed(context, routeName);
    });
  }
}
