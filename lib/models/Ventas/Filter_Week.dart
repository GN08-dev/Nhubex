import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Button/Sucursales.dart';
import 'package:flutter_proyect/components/Graph/Grafica_linea.dart';

class VentasXSemana extends StatefulWidget {
  final List<dynamic> datosTemporales;

  const VentasXSemana({super.key, required this.datosTemporales});

  @override
  _VentasXSemanaState createState() => _VentasXSemanaState();
}

class _VentasXSemanaState extends State<VentasXSemana> {
  bool loading = false;
  double totalValorNetoSemana = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';

  @override
  void initState() {
    super.initState();
    calculateData();
  }

  void calculateData() {
    // Obtener el primer día de la semana (lunes)
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    // Obtener el último día de la semana (domingo)
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Filtrar los datos de la semana
    List<dynamic> datosSemana = widget.datosTemporales.where((registro) {
      // Convertir la fecha del registro a DateTime
      DateTime fecha = DateTime.parse(registro["Fecha"]);
      // Verificar si la fecha está dentro de la semana
      return fecha.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          fecha.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();

    // Extraer los campos de los datos de la semana y guardarlos en arreglos
    List<String> nombres = [];
    List<double> valoresNetos = [];
    datosSemana.forEach((registro) {
      nombres.add(registro["Nombre"]);
      valoresNetos.add(double.parse(registro["ValorNeto"].toString()));
    });

    // Calcular el total del valor neto de la semana
    totalValorNetoSemana = valoresNetos.fold(0, (sum, valor) => sum + valor);

    // Encontrar la sucursal con más ventas
    Map<String, int> conteoSucursales = {};
    nombres.forEach((nombre) {
      conteoSucursales[nombre] = (conteoSucursales[nombre] ?? 0) + 1;
    });
    mejorSucursal = conteoSucursales.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Encontrar el mejor vendedor de la mejor sucursal
    List vendedoresMejorSucursal = datosSemana
        .where((registro) => registro["Nombre"] == mejorSucursal)
        .map((registro) => registro["Vendedor"])
        .toList();
    Map<String, int> conteoVendedores = {};
    vendedoresMejorSucursal.forEach((vendedor) {
      conteoVendedores[vendedor] = (conteoVendedores[vendedor] ?? 0) + 1;
    });
    mejorVendedor = conteoVendedores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 300,
                    color: Colors.white,
                    child: const LineChartSample2(),
                    // Puedes mostrar un gráfico o cualquier otro widget aquí
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Widget para seleccionar la sucursal
                        const SucursalWidget(),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Total Valor Neto: $totalValorNetoSemana',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Sucursal Estrella: $mejorSucursal',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Mejor vendedor de sucursal: $mejorVendedor',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
