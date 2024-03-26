import 'package:flutter/material.dart';

class VentasXSemana extends StatelessWidget {
  final List<dynamic> datosTemporales;

  const VentasXSemana({super.key, required this.datosTemporales});

  List<Widget> _buildDataWidgets(List<dynamic> data) {
    return data.map<Widget>((registro) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${registro["Fecha"]}'),
                Text('ValorNeto: ${registro["ValorNeto"]}'),
                Text('Vendedor: ${registro["Vendedor"]}'),
                Text('Vendedor2: ${registro["Vendedor2"]}'),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    // Obtener el primer día de la semana (lunes)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Obtener el último día de la semana (domingo)
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    // Filtrar los datos de la semana
    List<dynamic> datosSemana = datosTemporales.where((registro) {
      // Convertir la fecha del registro a DateTime
      DateTime fecha = DateTime.parse(registro["Fecha"]);
      // Verificar si la fecha está dentro de la semana
      return fecha.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
          fecha.isBefore(endOfWeek.add(Duration(days: 1)));
    }).toList();

    print('Datos de la semana: $datosSemana');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: _buildDataWidgets(datosSemana),
        ),
      ),
    );
  }
}
