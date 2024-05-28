import 'package:flutter_proyect/Pruebas/table_columns.dart';

class TableDataHelper {
  static List<TableColumns> kTableColumnsList = [
    TableColumns(title: 'Ubicacion', width: 80),
    TableColumns(title: 'Nombre', width: 150),
    TableColumns(title: 'Venta Neta', width: 80),
    TableColumns(title: 'Devolucion', width: 80),
    TableColumns(title: 'Ventas Menos Devolucion', width: 160),
    TableColumns(title: 'Venta Sin Impuesto', width: 160),
    TableColumns(title: 'Impuestos', width: 80),
    TableColumns(title: 'Tickets', width: 80),
    TableColumns(title: 'Promedio Tickets', width: 160),
    TableColumns(title: 'Piezas', width: 80),
  ];
}
