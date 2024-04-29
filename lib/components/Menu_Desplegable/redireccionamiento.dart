import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/router/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuHelper {
  // Función para manejar las acciones de los botones
  static void handleButtonTap(BuildContext context, Map<String, dynamic> item) {
    print('Tocaste ${item['title']}');
    if (item['title'] == 'Regresar') {
      Navigator.pop(context);
    } else if (item['title'] == 'Cerrar Sesión') {
      AppRouter.cerrarSesion();
      navigateDelayed(context, '/login');
    } else if (item['title'] == 'Menú') {
      navigateDelayed(context, '/menu');
    } else if (item['title'] == 'Reportes') {
      navigateDelayed(context, '/Reportes');
    } else if (item['title'] == 'Registro') {
      navigateDelayed(context, '/Registro');
    } else if (item['title'] == 'Prenomina') {
      navigateDelayed(context, '/Prenomina');
    }
  }

  // Función para manejar los informes de informes
  static void handleReportesTap(
      BuildContext context, Map<String, dynamic> item) {
    print('Tocaste ${item['title']}');
    if (item['title'] == 'Reportes') {
      Navigator.pushNamed(context, '/Reportes');
    } else if (item['title'] == 'Impresiones') {
      Navigator.pushNamed(context, '/Impresiones');
    } else if (item['title'] == 'Registro') {
      Navigator.pushNamed(context, '/Registro');
    } else if (item['title'] == 'Prenomina') {
      Navigator.pushNamed(context, '/Prenomina');
    }
  }

  // Función para obtener el rol del usuario de SharedPreferences
  static Future<String> obtenerRolUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rol = prefs.getString('rol');
    return rol ?? ''; // Devuelve el rol o una cadena vacía si no se encuentra
  }

  static Future<String> obtenerNombreEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombreEmpresa = prefs.getString('nombreEmpresa');
    return nombreEmpresa ?? 'Nombre de la Empresa';
  }

  // Función para restablecer el color después de un retraso
  static void resetColorAfterDelay(BuildContext context,
      Map<String, dynamic> item, Map<String, Color> itemColors) {
    Future.delayed(const Duration(milliseconds: 200), () {
      itemColors[item['title']] = Colors.transparent;
      // Asegúrate de que itemColors sea accesible desde aquí.
    });
  }

  // Función para navegar con un retraso
  static void navigateDelayed(BuildContext context, String routeName) {
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.pushReplacementNamed(context, routeName);
    });
  }

  // Función para obtener el nombre del usuario de SharedPreferences
  static Future<String> obtenerNombreUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nombre = prefs.getString('Nombre');
    return nombre ?? 'Usuario';
  }

  static Future<String> obtenersiglasEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? empresaSiglas = prefs.getString('empresa');
    return empresaSiglas ?? 'empresaSiglas';
  }
}
