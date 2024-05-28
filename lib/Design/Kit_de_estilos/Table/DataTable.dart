import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns; // Lista de columnas
  final List<DataRow> rows; // Lista de filas
  final List<DataRow> footerRows; // Lista de filas de pie de columna
  final TextStyle headerStyle; // Estilo para los encabezados
  final TextStyle rowStyle; // Estilo para las filas
  final TextStyle footerStyle; // Estilo para los pies de columna
  final double columnSpacing; // Espaciado entre columnas

  const CustomDataTable({
    Key? key,
    required this.columns,
    required this.rows,
    required this.footerRows,
    this.headerStyle = const TextStyle(
        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
    this.rowStyle = const TextStyle(color: Colors.black, fontSize: 16),
    this.footerStyle = const TextStyle(
        color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
    this.columnSpacing = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Combina las filas y las filas de pie de columna en una lista
    final allRows = List<DataRow>.from(rows)..addAll(footerRows);

    return DataTable(
      columns: columns.map((column) {
        return DataColumn(
          label: Center(
            child: column.label is Text
                ? column.label as Text
                : Text(
                    column.label.toString(),
                    style: headerStyle,
                  ),
          ),
          numeric: column.numeric,
          tooltip: column.tooltip,
        );
      }).toList(),
      rows: allRows.map((row) {
        return DataRow(
          cells: row.cells.map((cell) {
            return DataCell(
              Center(
                child: DefaultTextStyle(
                  style: rowStyle,
                  child: cell.child,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
      showBottomBorder: true,
      dividerThickness: 1,
      headingRowColor: MaterialStateProperty.all(
          Colors.grey.shade300), // Color gris para encabezados
      headingTextStyle: headerStyle, // Estilo de encabezados
      dataRowColor: MaterialStateProperty.all(Colors.transparent),
      dataTextStyle: footerStyle,
    );
  }
}
