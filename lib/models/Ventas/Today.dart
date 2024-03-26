import 'package:flutter/material.dart';

class DiaVentas extends StatelessWidget {
  final List<dynamic> datosTemporales;

  const DiaVentas({super.key, required this.datosTemporales});

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
    // Obtener la fecha actual
    DateTime now = DateTime.now();
    // Filtrar los datos del día actual
    List<dynamic> datosDia = datosTemporales.where((registro) {
      // Convertir la fecha del registro a DateTime
      DateTime fecha = DateTime.parse(registro["Fecha"]);
      // Verificar si la fecha coincide con el día actual
      return fecha.year == now.year &&
          fecha.month == now.month &&
          fecha.day == now.day;
    }).toList();

    return Scaffold(
      //backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (datosDia.isNotEmpty) ..._buildDataWidgets(datosDia),
            if (datosDia.isEmpty)
              const Center(
                child: Text(
                  'No hay datos actualmente',
                  style: TextStyle(color: Color.fromARGB(255, 31, 31, 31)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
