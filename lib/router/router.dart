import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/components/Paginas/Reportes.dart';
import 'package:flutter_proyect/src/Menu_Principal.dart';
import 'package:flutter_proyect/src/login.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == '/') {
      return MaterialPageRoute(
        builder: (_) => FutureBuilder<String?>(
          future: obtenerNombreEmpresa(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return SideMenu(companyName: snapshot.data!);
            } else {
              return const SideMenu(companyName: '');
            }
          },
        ),
      );
    } else if (settings.name == '/login') {
      return MaterialPageRoute(builder: (_) => const MyAppForm());
      //primera ruta
    } else if (settings.name == '/menu') {
      return MaterialPageRoute(
        builder: (_) => FutureBuilder<String?>(
          future: obtenerNombreEmpresa(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return MainMenu(companyName: snapshot.data!);
            } else {
              return const MainMenu(companyName: '');
            }
          },
        ),
      );
      //nueva ruta
    } else if (settings.name == '/Reportes') {
      return MaterialPageRoute(
        builder: (_) => FutureBuilder<String?>(
          future: obtenerNombreEmpresa(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return ReportesMain(companyName: snapshot.data!);
            } else {
              return const MainMenu(companyName: '');
            }
          },
        ),
      );
    } else {
      return null;
    }
  }

  static Future<String?> obtenerNombreEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre_empresa');
  }

  static Future<void> cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('nombre_empresa');
  }
}
