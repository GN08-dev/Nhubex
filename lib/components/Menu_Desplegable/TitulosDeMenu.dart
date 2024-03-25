import 'package:flutter/material.dart';

class MenuDataProvider {
  static final List<Map<String, dynamic>> sideMenus = [
    {'title': 'Menú', 'icon': Icons.home},
    {'title': 'Búsqueda', 'icon': Icons.search},
    {'title': 'Configuración', 'icon': Icons.settings},
    {'title': 'Cerrar Sesión', 'icon': Icons.logout},
    {'title': 'Regresar', 'icon': Icons.arrow_back}
  ];

  static List<Map<String, dynamic>> getSideMenus() {
    return sideMenus;
  }
}
