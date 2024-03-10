import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/info_card.dart';
import 'package:flutter_proyect/utils/Menu_Desplegable/TitulosDeMenu.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final sideMenus = MenuDataProvider.getSideMenus();

    return Drawer(
      child: Container(
        color: const Color.fromARGB(255, 31, 46, 93),
        width: 250,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              const InfoCard(
                name: "elote",
                profession: "casa elotes",
              ),
              const SizedBox(
                height: 15.0,
                child: Divider(color: Colors.grey),
              ),
              ...sideMenus.map((item) {
                return ListTile(
                  onTap: () {
                    // Acción a realizar cuando se toque el elemento
                    print('Tocaste ${item['title']}');
                    if (item['title'] == 'Regresar') {
                      Navigator.pop(context); // Cerrar el Drawer
                    } else if (item['title'] == 'Cerrar Sesión') {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
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
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
