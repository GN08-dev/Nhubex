import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class TestPrueba1 extends StatefulWidget {
  const TestPrueba1({super.key});

  @override
  _TestPrueba1State createState() => _TestPrueba1State();
}

class _TestPrueba1State extends State<TestPrueba1> {
  // Variables de estado
  bool loading = false;
  double totalValorNetoMes = 0.0;

  // Mapas para almacenar datos procesados
  Map<String, double> ventasPorIDHub = {};
  Map<String, double> ventasSinImpuestosPorIDHub = {};
  Map<String, String> sucursalesPorIDHub = {}; // Mapa para sucursales por IDHub

  // Datos temporales
  late List<dynamic> datosTemporales;
  String selectedIdHub = 'Todos los IDHub';
  String selectedSucursal = 'Todas las sucursales';
  List<String> idHubOptions = [];
  List<String> sucursalesOptions = [
    'Todas las sucursales'
  ]; // Opciones para el DropdownButton

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Método para obtener datos desde una API
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
        print('Datos temporales: $datosTemporales');

        obtenerIdHubOptions();
        obtenerSucursalesPorIDHub(); // Llama a la función para obtener sucursales por IDHub
        calcularDatos();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      mostrarError('Error al cargar los datos');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  // Muestra un mensaje de error en la interfaz de usuario.
  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Obtiene las opciones de IDHub a partir de los datos temporales.
  void obtenerIdHubOptions() {
    idHubOptions = datosTemporales
        .map((registro) => registro['IDHub'].toString())
        .toSet()
        .toList();
    idHubOptions.insert(0, 'Todos los IDHub');
  }

  // Obtiene las sucursales asociadas con cada IDHub
  void obtenerSucursalesPorIDHub() {
    for (var registro in datosTemporales) {
      String idHub = registro['IDHub'].toString();
      String sucursal = registro['Nombre'].toString();

      // Almacena la sucursal asociada con cada IDHub
      sucursalesPorIDHub[idHub] = sucursal;
      if (!sucursalesOptions.contains(sucursal)) {
        sucursalesOptions.add(sucursal);
      }
    }
  }

  // Calcula los datos necesarios para la interfaz de usuario.
  void calcularDatos() {
    List<dynamic> datosFiltrados =
        filtrarDatosPorIdHubYSucursal(selectedIdHub, selectedSucursal);

    totalValorNetoMes =
        datosFiltrados.fold<double>(0.0, (previousValue, registro) {
      double valorNeto = double.tryParse(registro['ValorNeto']) ?? 0.0;
      return previousValue + valorNeto;
    });

    ventasPorIDHub = obtenerVentasPorIDHub(datosFiltrados);
    ventasSinImpuestosPorIDHub =
        obtenerVentasSinImpuestosPorIDHub(datosFiltrados);
  }

  // Filtra los datos por el IDHub y la sucursal seleccionados.
  List<dynamic> filtrarDatosPorIdHubYSucursal(String idHub, String sucursal) {
    return datosTemporales.where((registro) {
      bool idHubCoincide =

          ///cambiar a sucursales  ////periodo
          idHub == 'Todos los IDHub' || registro['IDHub'].toString() == idHub;
      bool sucursalCoincide = sucursal == 'Todas las sucursales' ||
          registro['Nombre'].toString() == sucursal;
      return idHubCoincide && sucursalCoincide;
    }).toList();
  }

  // Obtiene las ventas totales por IDHub.
  Map<String, double> obtenerVentasPorIDHub(List<dynamic> datosFiltrados) {
    Map<String, double> ventasPorIDHub = {};
    for (var registro in datosFiltrados) {
      String idHub = registro['IDHub'].toString();
      double valorNeto = double.tryParse(registro['ValorNeto']) ?? 0.0;
      ventasPorIDHub[idHub] = (ventasPorIDHub[idHub] ?? 0) + valorNeto;
    }
    return ventasPorIDHub;
  }

  // Método corregido para obtener las ventas sin impuestos por IDHub
  Map<String, double> obtenerVentasSinImpuestosPorIDHub(
      List<dynamic> datosFiltrados) {
    Map<String, double> ventasSinImpuestosPorIDHub = {};
    for (var registro in datosFiltrados) {
      String idHub = registro['IDHub'].toString();
      double valorSinImpuestos = double.tryParse(registro['Valor']) ?? 0.0;
      // Sumar correctamente el valor sin impuestos
      ventasSinImpuestosPorIDHub[idHub] =
          (ventasSinImpuestosPorIDHub[idHub] ?? 0) + valorSinImpuestos;
    }
    return ventasSinImpuestosPorIDHub;
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: selectedIdHub,
              onChanged: (String? newValue) {
                setState(() {
                  selectedIdHub = newValue!;
                  calcularDatos();
                });
              },
              items: idHubOptions.map<DropdownMenuItem<String>>((String value) {
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
          : totalValorNetoMes == 0.0
              ? const Center(
                  child: Text(
                    'No hay datos disponibles para el mes actual.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        currentMonth,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${NumberFormat('#,##0.00').format(totalValorNetoMes)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 250,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SalesBarChart(_createSampleData()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // DataTable debajo de la gráfica
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: [
                                  const DataColumn(
                                    label: Text(
                                      'IDHub',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Row(
                                      children: [
                                        DropdownButton<String>(
                                          value: selectedSucursal,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedSucursal = newValue!;
                                              calcularDatos();
                                            });
                                          },
                                          items: sucursalesOptions
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Neto ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Venta sin impuesto',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const DataColumn(
                                    label: Text(
                                      'Total Bruto',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: ventasPorIDHub.entries
                                    .map(
                                      (entry) => DataRow(
                                        cells: [
                                          DataCell(Text(entry.key)),
                                          DataCell(Text(
                                              sucursalesPorIDHub[entry.key]!)),
                                          DataCell(
                                            Text(
                                              '\$${NumberFormat('#,##0.00').format(entry.value)}',
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              '\$${NumberFormat('#,##0.00').format(ventasSinImpuestosPorIDHub[entry.key] ?? 0.0)}',
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              '\$${NumberFormat('#,##0.00').format(entry.value / (ventasSinImpuestosPorIDHub[entry.key] ?? 0.0))}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  List<BarChartGroupData> _createSampleData() {
    double maxSales = 0;
    Map<String, double> ventasPorIDHub = {};
    //agregar los periodos , dia, mes, mes pasado , mes actual , dia pasado , semana pasada , semana actual
    if (selectedIdHub == 'Todos los IDHub') {
      datosTemporales.forEach((registro) {
        String idHub = registro['IDHub'].toString();
        double valorNeto = double.tryParse(registro['ValorNeto']) ?? 0.0;
        ventasPorIDHub[idHub] = (ventasPorIDHub[idHub] ?? 0) + valorNeto;
      });
    } else {
      datosTemporales.forEach((registro) {
        if (registro['IDHub'].toString() == selectedIdHub) {
          double valorNeto = double.tryParse(registro['ValorNeto']) ?? 0.0;
          ventasPorIDHub[selectedIdHub] =
              (ventasPorIDHub[selectedIdHub] ?? 0) + valorNeto;
        }
      });
    }

    // Ordenar los IDHub por sus ventas de forma descendente
    List<String> sortedIds = ventasPorIDHub.keys.toList()
      ..sort((a, b) => ventasPorIDHub[b]!.compareTo(ventasPorIDHub[a]!));

    // Tomar solo los primeros 5 IDHub
    sortedIds = sortedIds.take(5).toList();
    maxSales = ventasPorIDHub.values.reduce(max);

    return List.generate(sortedIds.length, (index) {
      final idHub = sortedIds[index];
      final ventas = ventasPorIDHub[idHub]!;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: ventas,
            color: Colors.blue,
            width: 35,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxSales,
              color: Colors.grey[300],
            ),
          ),
        ],
      );
    });
  }
}

class SalesBarChart extends StatelessWidget {
  final List<BarChartGroupData> seriesList;

  const SalesBarChart(this.seriesList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barGroups: seriesList,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          //leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (BarChartGroupData group) =>
                const Color.fromARGB(255, 251, 252, 252),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
