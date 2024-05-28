import 'package:flutter/material.dart';

class MenuDataProvider {
  static final List<Map<String, dynamic>> sideMenus = [
    {'title': 'Menú', 'icon': Icons.home},
    {'title': 'Reportes', 'icon': Icons.pending_actions_rounded},
    {'title': 'Registro', 'icon': Icons.people},
    {'title': 'Cerrar Sesión', 'icon': Icons.logout},
    {'title': 'Regresar', 'icon': Icons.arrow_back},
  ];

  static List<Map<String, dynamic>> getSideMenus() {
    return sideMenus;
  }
}

class MenuDataProviderUsuario {
  static final List<Map<String, dynamic>> sideMenusUsuario = [
    {'title': 'Menú', 'icon': Icons.home},
    {'title': 'Reportes', 'icon': Icons.pending_actions_rounded},
    {'title': 'Cerrar Sesión', 'icon': Icons.logout},
    {'title': 'Regresar', 'icon': Icons.arrow_back},
  ];

  static List<Map<String, dynamic>> getSideMenusUsuario() {
    return sideMenusUsuario;
  }
}
