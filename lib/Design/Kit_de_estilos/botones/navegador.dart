import 'package:flutter/material.dart';
import 'package:flutter_proyect/models/Registro/Registro.dart';
import 'package:flutter_proyect/models/Ventas/Venta_Consolidada_Rango_Fechas.dart';
import 'package:flutter_proyect/models/Ventas/Venta_Forma_Pago_Consolidada.dart';
import 'package:flutter_proyect/models/Ventas/Ventas_Sucursal_Detalle.dart';

class Reportes {
  static void handleButtonTap(BuildContext context, Map<String, dynamic> item) {
    print('Tocaste ${item['title']}');

    if (item['title'] == 'Inventario de Extracto costo Almacen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro()),
      );
    } else if (item['title'] == 'Inventario de referencia') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro()),
      );
    } else if (item['title'] == 'Inventario negativo') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro()),
      );

      //monitoreo
    } else if (item['title'] == 'Monitoreo de almacen') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro()),
      );
    } else if (item['title'] == 'Monitoreo de clientes') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro()),
      );
    } else if (item['title'] == 'Monitoreo de Usuario') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const Registro()),
      );

      ///ventas
    } else if (item['title'] == 'Venta por Forma de Pago') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VentaFormaPagoConsolidada()),
      );
    } else if (item['title'] == 'Venta por Sucursal') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => const VentasSucursalDetalle()), //listo
      );
    } else if (item['title'] == 'Venta Consolidada por Rango de Fechas') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VentaConsilidada()),
      );

      //otros
    } else {
      print('Opción no reconocida');
    }
  }
}
