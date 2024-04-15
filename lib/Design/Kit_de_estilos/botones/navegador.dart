import 'package:flutter/material.dart';
import 'package:flutter_proyect/models/Registro/Resgistro.dart';
import 'package:flutter_proyect/models/Ventas/Ventas.dart';

class Reportes {
  static void handleButtonTap(BuildContext context, Map<String, dynamic> item) {
    print('Tocaste ${item['title']}');

    if (item['title'] == 'Inventario de Extracto costo Almacen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Inventario de referencia') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Inventario negativo') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Monitoreo de almacen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Monitoreo de clientes') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Monitoreo de Usuario') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Ventas del diario') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Ventas()),
      );
    } else if (item['title'] == 'Ventas por punto de venta') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Ventas por referencia') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Ventas por vendedor') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Consulta de producto') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else if (item['title'] == 'Consulta de productos (cámara)') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro(companyName: '')),
      );
    } else {
      print('Opción no reconocida');
    }
  }
}
