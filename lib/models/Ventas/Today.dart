import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Button/Sucursales.dart';
import 'package:flutter_proyect/components/Graph/Grafica_linea.dart';

class DiaVentas extends StatefulWidget {
  final List<dynamic> datosTemporales;

  const DiaVentas({Key? key, required this.datosTemporales});

  @override
  _DiaVentasState createState() => _DiaVentasState();
}

class _DiaVentasState extends State<DiaVentas> {
  bool loading = true;
  double totalValorNetoDia = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    // Esperar hasta que haya datos temporales disponibles
    while (widget.datosTemporales.isEmpty) {
      await Future.delayed(Duration(
          seconds: 1)); // Esperar 1 segundo antes de verificar de nuevo
    }

    // Indicar que estamos cargando los datos
    setState(() {
      loading = true;
    });

    // Filtrar los datos del día actual
    List<dynamic> datosDia = widget.datosTemporales.where((registro) {
      // Convertir la fecha del registro a DateTime
      DateTime fecha = DateTime.parse(registro["Fecha"]);
      // Obtener la fecha actual
      DateTime now = DateTime.now();
      // Verificar si la fecha coincide con el día actual
      return fecha.year == now.year &&
          fecha.month == now.month &&
          fecha.day == now.day;
    }).toList();

    // Extraer los campos de los datos del día y guardarlos en arreglos
    List<String> nombres = [];
    List<double> valoresNetos = [];
    datosDia.forEach((registro) {
      nombres.add(registro["Nombre"]);
      valoresNetos.add(double.parse(registro["ValorNeto"].toString()));
    });

    // Calcular el total del valor neto del día
    totalValorNetoDia = valoresNetos.fold(0, (sum, valor) => sum + valor);

    // Encontrar la sucursal con más ventas
    Map<String, int> conteoSucursales = {};
    nombres.forEach((nombre) {
      conteoSucursales[nombre] = (conteoSucursales[nombre] ?? 0) + 1;
    });
    mejorSucursal = conteoSucursales.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Encontrar el mejor vendedor de la mejor sucursal
    List vendedoresMejorSucursal = datosDia
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

    // Indicar que se han cargado los datos
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 300,
                    color: Colors.white,
                    child: const LineChartSample2(),
                    // Puedes mostrar un gráfico u otro widget aquí
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
                          'Total Valor Neto: $totalValorNetoDia',
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
