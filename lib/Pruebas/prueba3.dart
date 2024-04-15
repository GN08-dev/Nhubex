import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/info_card.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Graficas/graphbar.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';

class TestPrueba2 extends StatefulWidget {
  const TestPrueba2({Key? key}) : super(key: key);

  @override
  _TestPrueba2State createState() => _TestPrueba2State();
}

class _TestPrueba2State extends State<TestPrueba2> {
  String nombreUsuario = '';
  String nombreEmpresa = '';

  // Variables de estado
  bool loading = false;
  double totalNeto = 0.0;
  double totalVentaSinImpuesto = 0.0;
  String selectedTimePeriod = 'Dia';
  String selectedSucursal = 'Sucursal';
  List<String> sucursalesOptions = ['Sucursal'];
  List<String> timePeriodOptions = [
    'Dia',
    'Dia pasado',
    'Mes',
    'Mes pasado',
    'Semana',
    'Semana pasada'
  ];
  List<dynamic> datosTemporales = [];
  List<String> sortedSucursales = [];

  // Nuevo mapa de relaciones entre sucursales e IDUbicacion
  Map<String, String> sucursalIDUbicacionMap = {};

  @override
  void initState() {
    super.initState();
    obtenerDatos();
    obtenerNombreUsuario();
    obtenerNombreEmpresa();
  }

  // Función para obtener el nombre del usuario
  Future<void> obtenerNombreUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString('Nombre') ?? '';
    });
  }

  // Función para obtener el nombre de la empresa
  Future<void> obtenerNombreEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreEmpresa = prefs.getString('nombre_empresa') ?? '';
    });
  }

  // Método para obtener datos de la API
  Future<void> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
      );

      if (response.statusCode == 200) {
        datosTemporales = json.decode(response.data)['RESPUESTA']['registro'];
        obtenerSucursales();
        calcularTotalventas();
        // Crear el mapa de relaciones entre sucursales e IDUbicacion
        for (var registro in datosTemporales) {
          final sucursal = registro['Sucursal'].toString();
          final idUbicacion = registro['IDUbicacion'].toString();

          // Agrega la relación entre sucursal e IDUbicacion al mapa
          sucursalIDUbicacionMap[sucursal] = idUbicacion;
        }
      } else {
        throw Exception('Fallo al cargar datos: ${response.statusCode}');
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

  // Método para mostrar errores
  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  // Método para calcular las ventas totales
  void calcularTotalventas() {
    final datosFiltrados = filtrarDatosPorPeriodo(selectedTimePeriod);
    double neto = 0.0;
    double ventaSinImpuesto = 0.0;

    for (var registro in datosFiltrados) {
      final String claveNeta = obtenerClaveNetaPorPeriodo(selectedTimePeriod);
      final String claveVentaSinImpuesto =
          obtenerClaveVentaSinImpuestoPorPeriodo(selectedTimePeriod);

      neto += double.tryParse(registro[claveNeta]) ?? 0.0;
      ventaSinImpuesto +=
          double.tryParse(registro[claveVentaSinImpuesto]) ?? 0.0;
    }

    setState(() {
      totalNeto = neto;
      totalVentaSinImpuesto = ventaSinImpuesto;
    });
  }

  // Método para filtrar datos por periodo de tiempo
  List<dynamic> filtrarDatosPorPeriodo(String periodo) {
    return datosTemporales;
  }

  // Método para obtener las sucursales únicas
  void obtenerSucursales() {
    final sucursalesSet = <String>{};

    // Recorre los datos temporales y agrega cada sucursal al conjunto
    for (var registro in datosTemporales) {
      final sucursal = registro['Sucursal'].toString();
      sucursalesSet.add(sucursal);
    }

    // Convierte el conjunto en una lista y establece las opciones de sucursal
    setState(() {
      sucursalesOptions = sucursalesSet.toList();
      sucursalesOptions.insert(0, 'Sucursal');
    });
  }

  String obtenerClaveVentaSinImpuestoPorPeriodo(String periodo) {
    if (periodo == 'Dia') {
      return 'VentaDia';
    } else if (periodo == 'Dia pasado') {
      return 'VentaDiaAnt';
    } else if (periodo == 'Mes') {
      return 'ValorMes';
    } else if (periodo == 'Mes pasado') {
      return 'MesPasvalor';
    } else if (periodo == 'Semana') {
      return 'Semanavalor';
    } else if (periodo == 'Semana pasada') {
      return 'SemanaPasValor';
    } else {
      throw Exception('Periodo desconocido');
    }
  }

  String obtenerClaveNetaPorPeriodo(String periodo) {
    if (periodo == 'Dia') {
      return 'NetoDia';
    } else if (periodo == 'Dia pasado') {
      return 'NetoDiaAnt';
    } else if (periodo == 'Mes') {
      return 'NetoMes';
    } else if (periodo == 'Mes pasado') {
      return 'MesPasNeto';
    } else if (periodo == 'Semana') {
      return 'SemanaNeto';
    } else if (periodo == 'Semana pasada') {
      return 'SemanaPasNeto';
    } else {
      throw Exception('Periodo desconocido');
    }
  }

  // Método para filtrar los datos por sucursal seleccionada
  List<dynamic> filtrarDatosPorSucursal(String sucursal) {
    return datosTemporales.where((registro) {
      if (sucursal == 'Sucursal') {
        return true;
      } else {
        return sucursal == registro['Sucursal'].toString();
      }
    }).toList();
  }

// Método para convertir los datos a un formato de gráficos de barras
  List<BarChartGroupData> convertirDatosAVentasBarChart(List<dynamic> datos) {
    Map<String, double> ventasPorIDUbicacion = {};
    double maxSales = 0; // Inicializa maxSales a 0

    for (var registro in datos) {
      String idUbicacion = registro['IDUbicacion'].toString();

      // Excluir "Todas las sucursales" de la gráfica
      if (idUbicacion == 'Sucursal') {
        continue;
      }

      // Obtener la clave neta por periodo
      final key = obtenerClaveNetaPorPeriodo(selectedTimePeriod);
      double valor = double.tryParse(registro[key]) ?? 0.0;
      // Actualiza ventasPorIDUbicacion
      ventasPorIDUbicacion[idUbicacion] =
          (ventasPorIDUbicacion[idUbicacion] ?? 0) + valor;
      // Actualiza maxSales con el valor máximo de ventas
      maxSales = max(maxSales, ventasPorIDUbicacion[idUbicacion]!);
    }

    maxSales += maxSales * 0.2;

    // Ordenar los IDs de ubicación por ventas
    sortedSucursales = ventasPorIDUbicacion.keys.toList()
      ..sort((a, b) =>
          ventasPorIDUbicacion[b]!.compareTo(ventasPorIDUbicacion[a]!));
    sortedSucursales = sortedSucursales.take(5).toList();

    List<BarChartGroupData> listaBarChartData =
        List.generate(sortedSucursales.length, (index) {
      final idUbicacion = sortedSucursales[index];
      final ventas = ventasPorIDUbicacion[idUbicacion]!;

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

    return listaBarChartData; // Retorna la lista de datos de barras
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el nombre del mes actual en español
    String currentMonth = DateFormat('MMMM', 'es_MX').format(DateTime.now());
    final datosFiltrados = filtrarDatosPorSucursal(selectedSucursal);
    final listaBarChartData = convertirDatosAVentasBarChart(datosFiltrados);

    return Scaffold(
      endDrawer: Drawer(
        child: Column(
          children: [
            // Parte superior del Drawer
            Container(
              color: const Color.fromRGBO(0, 184, 239, 1),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  InfoCard(
                    name: nombreUsuario,
                    profession: nombreEmpresa,
                  ),
                ],
              ),
            ),

            // Parte inferior del Drawer
            Expanded(
              child: Container(
                color: const Color.fromRGBO(46, 48, 53, 1),
                child: ListView(
                  children: [
                    // ExpansionTile para seleccionar la sucursal
                    ExpansionTile(
                      title: const Text(
                        'Select Sucursal',
                        style: TextStyle(color: Colors.white),
                      ),
                      children: sucursalesOptions.map((sucursal) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedSucursal = sucursal;
                              calcularTotalventas();
                              // Cerrar el ExpansionTile
                            });
                          },
                          child: Container(
                            color: Colors.black26,
                            child: ListTile(
                              title: Text(
                                sucursal,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // ExpansionTile para seleccionar el periodo de tiempo
                    ExpansionTile(
                      title: const Text(
                        'Selecciona el periodo',
                        style: TextStyle(color: Colors.white),
                      ),
                      children: timePeriodOptions.map((period) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedTimePeriod = period;
                              calcularTotalventas();
                              // Cerrar el ExpansionTile
                            });
                          },
                          child: Container(
                            color: Colors
                                .black26, // Cambia el color de fondo a rojo
                            child: ListTile(
                              title: Text(
                                period,
                                style: const TextStyle(color: Colors.white),
                              ),
                              // Elimina los subrayados blancos de ListTile
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Ventas'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : totalNeto == 0.0
              ? const Center(
                  child: Text(
                    'No hay datos disponibles para el período seleccionado.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      currentMonth.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      ' \$${NumberFormat(
                        "#,##0.00",
                      ).format(totalNeto)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Llamar a SalesBarChart con xTitles
                    SizedBox(
                      height: 260,
                      child: SalesBarChart(
                        listaBarChartData,
                        sortedSucursales,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Crear la tabla usando CustomDataTable
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: CustomDataTable(
                              columns: const [
                                DataColumn(label: Text('Cod')),
                                DataColumn(label: Text('Sucursal')),
                                DataColumn(label: Text('Neto')),
                                DataColumn(label: Text('Venta sin impuesto')),
                                DataColumn(label: Text('Total Bruto')),
                              ],
                              rows: [
                                ...datosFiltrados.map((registro) {
                                  final String claveNeta =
                                      obtenerClaveNetaPorPeriodo(
                                          selectedTimePeriod);
                                  final double valorNeto = double.tryParse(
                                          registro[claveNeta] ?? '0') ??
                                      0.0;
                                  final String valorNetoFormateado =
                                      NumberFormat("#,##0.00")
                                          .format(valorNeto);

                                  final String claveVentaSinImpuesto =
                                      obtenerClaveVentaSinImpuestoPorPeriodo(
                                          selectedTimePeriod);
                                  final double valorVentaSinImpuesto =
                                      double.tryParse(
                                              registro[claveVentaSinImpuesto] ??
                                                  '0') ??
                                          0.0;
                                  final String valorVentaSinImpuestoFormateado =
                                      NumberFormat("#,##0.00")
                                          .format(valorVentaSinImpuesto);

                                  // Agrega las celdas a la fila
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(registro['IDUbicacion'])),
                                      DataCell(Text(registro['Sucursal'])),
                                      DataCell(
                                          Text('\$${valorNetoFormateado}')),
                                      DataCell(Text(
                                          '\$${valorVentaSinImpuestoFormateado}')),
                                      const DataCell(Text('sin info')),
                                    ],
                                  );
                                }).toList(),
                              ],
                              // Pasa la fila de totales como `footerRows`
                              footerRows: [
                                DataRow(
                                  cells: [
                                    const DataCell(Text('')),
                                    const DataCell(Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    )),
                                    DataCell(
                                      Text(
                                        '\$${NumberFormat("#,##0.00").format(totalNeto)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '\$${NumberFormat("#,##0.00").format(totalVentaSinImpuesto)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const DataCell(Text(
                                      'sin info',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    )),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    )
                  ],
                ),
    );
  }
}
