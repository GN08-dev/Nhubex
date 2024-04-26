import 'package:flutter/material.dart';
import 'package:flutter_proyect/models/Reportes/Reportes.dart';
import 'package:flutter_proyect/models/Registro/Resgistro.dart';
import 'package:flutter_proyect/models/prenomina/prenomina.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menu_inicio_Administrador/Menu_Principal_Administrador.dart';
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
              return Menu_Lateral(companyName: snapshot.data!);
            } else {
              return const Menu_Lateral(companyName: '');
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
              return Menu_Principal_Administrador(companyName: snapshot.data!);
            } else {
              return const Menu_Principal_Administrador(companyName: '');
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
              return const Menu_Principal_Administrador(companyName: '');
            }
          },
        ),
      );
    } else if (settings.name == '/Registro') {
      return MaterialPageRoute(
        builder: (_) => FutureBuilder<String?>(
          future: obtenerNombreEmpresa(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              return Registro(companyName: snapshot.data!);
            } else {
              return Registro(companyName: snapshot.data!);
            }
          },
        ),
      );
    } else if (settings.name == '/Prenomina') {
      return MaterialPageRoute(
        builder: (_) => FutureBuilder(
            future: obtenerNombreEmpresa(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasData) {
                return Prenomina(companyName: snapshot.data!);
              } else {
                return const Registro(companyName: "");
              }
            }),
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
    await prefs.clear();
  }
}
