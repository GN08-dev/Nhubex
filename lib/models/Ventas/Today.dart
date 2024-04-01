import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:intl/intl.dart';

class VentaXDia extends StatefulWidget {
  final String companyName;

  const VentaXDia({super.key, required this.companyName});

  @override
  _VentaXDiaState createState() => _VentaXDiaState();
}

class _VentaXDiaState extends State<VentaXDia> {
  bool loading = false;
  double totalValorNetoDia = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';
  late List<dynamic> datosTemporales;
  late List<double> ventasPorDiaList;
  late int currentDayOfWeek;
  late List<String> sucursalesDisponibles = [];
  String selectedSucursal = '';

  @override
  void initState() {
    super.initState();
    currentDayOfWeek = DateTime.now().weekday;
    getData();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    try {
      Response response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
      );

      if (response.statusCode == 200) {
        datosTemporales = json.decode(response.data)["RESPUESTA"]["registro"];
        sucursalesDisponibles = obtenerSucursales(datosTemporales);
        if (sucursalesDisponibles.isNotEmpty) {
          selectedSucursal = sucursalesDisponibles.first;
        }
        calculateData();
        setState(() {
          loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error: $e');
    }
  }

  List<String> obtenerSucursales(List<dynamic> datos) {
    Set<String> sucursales = {};
    datos.forEach((registro) {
      String nombre = registro["Nombre"];
      sucursales.add(nombre);
    });
    return ['Todas las Sucursales', ...sucursales.toList()];
  }

  void calculateData() {
    Map<int, double> ventasPorDia = {};

    for (int day = 1; day <= 7; day++) {
      ventasPorDia[day] = 0.0;
    }

    datosTemporales.forEach((registro) {
      dynamic valorNetoData = registro['ValorNeto'];
      if (valorNetoData != null) {
        double valorNeto = double.parse(valorNetoData);
        dynamic fechaData = registro['Fecha'];
        String sucursal = registro['Nombre'];
        if (fechaData != null &&
            (selectedSucursal == 'Todas las Sucursales' ||
                sucursal == selectedSucursal)) {
          DateTime date = DateTime.parse(fechaData);
          int day = date.weekday;
          if (day == currentDayOfWeek) {
            ventasPorDia[day] = ventasPorDia[day]! + valorNeto;
          }
        }
      }
    });

    ventasPorDiaList = ventasPorDia.values.toList();

    totalValorNetoDia =
        ventasPorDia.values.fold(0, (sum, valor) => sum + valor);

    if (totalValorNetoDia == 0.0) {
      // No hay datos disponibles para el día actual, reiniciar valores
      totalValorNetoDia = 0.0;
      mejorSucursal = '';
      mejorVendedor = '';
      return;
    }

    if (selectedSucursal == 'Todas las Sucursales') {
      Map<String, double> ventasPorSucursal = {};

      datosTemporales.forEach((registro) {
        dynamic valorNetoData = registro['ValorNeto'];
        if (valorNetoData != null) {
          double valorNeto = double.parse(valorNetoData);
          String sucursal = registro['Nombre'];
          ventasPorSucursal[sucursal] =
              (ventasPorSucursal[sucursal] ?? 0) + valorNeto;
        }
      });

      mejorSucursal = ventasPorSucursal.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
    } else {
      mejorSucursal = selectedSucursal;
    }

    Map<String, int> conteoVendedores = {};
    datosTemporales
        .where((registro) =>
            selectedSucursal == 'Todas las Sucursales' ||
            registro["Nombre"] == selectedSucursal)
        .forEach((registro) {
      String vendedor = registro["Vendedor"];
      conteoVendedores[vendedor] = (conteoVendedores[vendedor] ?? 0) + 1;
    });
    mejorVendedor = conteoVendedores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            DropdownButton<String>(
              value: selectedSucursal,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSucursal = newValue!;
                  calculateData();
                });
              },
              items: sucursalesDisponibles
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : totalValorNetoDia == 0.0
              ? const Center(
                  child: Text(
                    'No hay datos disponibles para el día actual.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.zero,
                    color: Colors.grey.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          currentMonth,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalValorNetoDia.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 1.70,
                          child: Padding(
                            padding: EdgeInsets.zero,
                            child: SalesBarChart(
                              _createSampleData(),
                              animate: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildContainerWithBackground(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.attach_money,
                                size: 45,
                                color: Color.fromARGB(255, 2, 128, 8),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Venta total:',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '\$${totalValorNetoDia.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildContainerWithBackground(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 45,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                selectedSucursal == 'Todas las Sucursales'
                                    ? 'Suc.Estrella'
                                    : 'Sucursal',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '$mejorSucursal',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildContainerWithBackground(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_border_purple500_outlined,
                                size: 45,
                                color: Color.fromARGB(255, 249, 168, 37),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Mejor vendedor',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '$mejorVendedor',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        _buildContainerWithBackground(
                          child: Row(children: [
                            const Icon(
                              Icons.shopping_cart,
                              size: 45,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Ventas',
                              style: TextStyle(fontSize: 18),
                            ),
                            const Spacer(),
                            Text(
                              '\$${totalValorNetoDia.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )
                          ]),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildContainerWithBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.8),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
      padding: const EdgeInsets.all(8),
    );
  }

  List<charts.Series<SalesData, String>> _createSampleData() {
    final data = List.generate(7, (index) {
      return SalesData(
          (index + 1).toString(),
          ventasPorDiaList[
              index]); // Sumamos 1 para que los días comiencen desde 1
    });

    final filteredData = data.where((element) => element.sales > 0.0).toList();

    return [
      charts.Series<SalesData, String>(
        id: 'Sales',
        domainFn: (SalesData sales, _) => sales.day,
        measureFn: (SalesData sales, _) => sales.sales,
        data: filteredData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        labelAccessorFn: (SalesData sales, _) =>
            '${sales.day}: \$${sales.sales.toStringAsFixed(2)}',
      )
    ];
  }
}

class SalesData {
  final String day;
  final double sales;

  SalesData(this.day, this.sales);
}

class SalesBarChart extends StatelessWidget {
  final List<charts.Series<SalesData, String>> seriesList;
  final bool animate;

  SalesBarChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      vertical: false,
      barRendererDecorator: charts.BarLabelDecorator<String>(
        labelPosition: charts.BarLabelPosition.outside,
      ),
    );
  }
}
