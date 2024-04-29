import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/models/Reportes/Reportes.dart';
import 'package:flutter_proyect/models/Registro/Resgistro.dart';
import 'package:flutter_proyect/models/prenomina/prenomina.dart';
import 'package:flutter_proyect/src/Menu_Principa.dart';
import 'package:flutter_proyect/src/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (_) => Menu_Lateral(),
      );
    } else if (settings.name == '/login') {
      return MaterialPageRoute(
        builder: (_) => MyAppForm(),
      );
    } else if (settings.name == '/menu') {
      return MaterialPageRoute(
        builder: (_) => Menu_Principal(),
      );
    } else if (settings.name == '/Reportes') {
      return MaterialPageRoute(
        builder: (_) => ReportesMain(),
      );
    } else if (settings.name == '/Registro') {
      return MaterialPageRoute(
        builder: (_) => Registro(),
      );
    } else if (settings.name == '/Prenomina') {
      return MaterialPageRoute(
        builder: (_) => Prenomina(),
      );
    } else {
      return null;
    }
  }

  // Método para cerrar sesión
  static Future<void> cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> verificarSesionIniciada() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');
    return uid != null;
  }
}
