import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/models/Reportes/Reportes.dart';
import 'package:flutter_proyect/models/Registro/Resgistro.dart';
import 'package:flutter_proyect/models/prenomina/prenomina.dart';
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
    await prefs.remove('nombre_empresa');
  }
}
/*
class RouterReportes {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    // ignore: unused_local_variable
    final args = settings.arguments as Map<String, dynamic>?;

    if (settings.name == '/inventario-extracto-costo-almacen') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/inventario-referencia') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/inventario-negativo') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/monitoreo-almacen') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/monitoreo-clientes') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/monitoreo-usuario') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/ventas-del-diario') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/ventas-por-punto-de-venta') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/ventas-por-referencia') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/ventas-por-vendedor') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/consulta-de-producto') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else if (settings.name == '/consulta-de-productos-camara') {
      return MaterialPageRoute(builder: (_) => const Registro(companyName: ''));
    } else {
      // Si la ruta no es reconocida, retornamos null o puedes manejar un caso por defecto.
      return null;
    }
  }
}
*/