/*import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Button/Sucursales.dart';

class MesVentas extends StatefulWidget {
  final List<dynamic> datosTemporales;

  const MesVentas({Key? key, required this.datosTemporales});

  @override
  State<MesVentas> createState() => _MesVentasState();
}

class _MesVentasState extends State<MesVentas> {
  bool loading = false;
  double totalValorNeto = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';

  @override
  void initState() {
    super.initState();
    calculateData();
  }

  void calculateData() {
    // Sumar el valor neto
    totalValorNeto = widget.datosTemporales.fold<double>(
      0.0,
      (sum, item) => sum + double.parse(item["ValorNeto"].toString()),
    );

    // Encontrar la mejor sucursal
    final sucursalCount = <String, int>{};
    widget.datosTemporales.map((item) => item["Nombre"]).forEach((sucursal) {
      sucursalCount[sucursal] = sucursalCount.containsKey(sucursal)
          ? sucursalCount[sucursal]! + 1
          : 1;
    });
    mejorSucursal =
        sucursalCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Encontrar el mejor vendedor de la mejor sucursal
    final vendedorCount = <String, int>{};
    widget.datosTemporales
        .where((item) => item["Nombre"] == mejorSucursal)
        .map((item) => item["Vendedor"])
        .forEach((vendedor) {
      vendedorCount[vendedor] = vendedorCount.containsKey(vendedor)
          ? vendedorCount[vendedor]! + 1
          : 1;
    });
    mejorVendedor =
        vendedorCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
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
                    // Aquí debes colocar el widget para el gráfico LineChart
                    child: Placeholder(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SucursalWidget(),
                        const SizedBox(height: 15),
                        Text(
                          'Total Valor Neto: $totalValorNeto',
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
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
*/