import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Graficas/graphbar.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VentaFormaPagoConsolidada extends StatefulWidget {
  const VentaFormaPagoConsolidada({Key? key});

  @override
  State<VentaFormaPagoConsolidada> createState() =>
      _VentaFormaPagoConsolidadaState();
}

class _VentaFormaPagoConsolidadaState extends State<VentaFormaPagoConsolidada> {
  String empresa = '';
  String nombre = '';
  bool loading = false;
  List<Map<String, dynamic>> datosC1 = [];
  double totalVenta = 0;
  double totalVentaNeta = 0;
  //filtro
  Map<String, String> sucursalesMap = {};
  String selectedSucursal =
      'Todas las sucursales'; // Inicializamos con "Todas las sucursales"
  List<String> sucursalesOptions = ['Todas las sucursales'];
  List<Map<String, dynamic>> filtrarDatosPorSucursalTabla(
      List<Map<String, dynamic>> datos, String sucursal) {
    if (sucursal == 'Todas las sucursales') {
      return datos;
    } else {
      return datos.where((dato) => dato['nombre'] == sucursal).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerNombreEmpresa();
    obtenerNombreUsuario().then((_) {
      if (nombre.isNotEmpty) {
        obtenerDatos().then((data) {
          setState(() {
            datosC1 = data;
          });
        });
      } else {
        mostrarError('Nombre de usuario no cargado.');
      }
    });
  }

  Future<String> obtenerNombreUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('Nombre') ?? '';
    });
    print('Nombre cargado de SharedPreferences: $nombre');
    return nombre;
  }

  Future<void> obtenerNombreEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empresa = prefs.getString('Nombre_Empresa') ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_consolidada_forma_pago&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%2211%22,%22uactivo%22:%22$nombre%22,%22fini%22:%222024-04-18%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        List<Map<String, dynamic>> datos = [];
        for (var item in c1Data) {
          // Convertir todas las ubicaciones a minúsculas
          item['ubicacion'] = (item['ubicacion'] as String).toLowerCase();
          datos.add(Map<String, dynamic>.from(item));
        }

        // Obtener nombres de sucursales y sus ubicaciones
        for (var dato in datos) {
          String nombreSucursal = dato['nombre'] ?? '';
          String ubicacion = dato['ubicacion'] ?? '';
          sucursalesMap[nombreSucursal] = ubicacion;
        }

        return datos;
      } else {
        mostrarError(
            'Error al obtener los datos del JSON. Código de estado: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      mostrarError('Error al cargar los datos.');
      return [];
    } finally {
      setState(() => loading = false);
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void calcularTotales() {
    totalVenta = 0;
    totalVentaNeta = 0;
    for (var dato in datosC1) {
      totalVenta += double.parse(dato['venta'] ?? '0');
      totalVentaNeta += double.parse(dato['venta_neta'] ?? '0');
    }
  }

  List<BarChartGroupData> convertirDatosAVentasBarChart(
      List<dynamic> datos, String sucursalSeleccionada) {
    Map<String, double> ventasPorIDUbicacion = {};

    // Filtra los datos por la sucursal seleccionada, si no es "Todas las sucursales"
    if (sucursalSeleccionada != 'Todas las sucursales') {
      final datosFiltrados = datos
          .where((dato) => dato['nombre'] == sucursalSeleccionada)
          .toList();

      for (var registro in datosFiltrados) {
        String idUbicacion = registro['ubicacion'].toString();
        double valor = double.tryParse(registro['venta_neta'] ?? '0.0') ?? 0.0;
        ventasPorIDUbicacion[idUbicacion] =
            (ventasPorIDUbicacion[idUbicacion] ?? 0) + valor;
      }
    } else {
      // Si se selecciona "Todas las sucursales", mostramos todas las ubicaciones
      for (var registro in datos) {
        String idUbicacion = registro['ubicacion'].toString();
        double valor = double.tryParse(registro['venta_neta'] ?? '0.0') ?? 0.0;
        ventasPorIDUbicacion[idUbicacion] =
            (ventasPorIDUbicacion[idUbicacion] ?? 0) + valor;
      }
    }

    // Redondear totalVentaNeta hacia arriba a la centena más cercana
    double maxSales = (ventasPorIDUbicacion.values
                    .fold<double>(0, (previous, current) => previous + current)
                    .ceilToDouble() /
                100000)
            .ceil() *
        100000;

    List<String> sortedSucursales = ventasPorIDUbicacion.keys.toList()
      ..sort((a, b) =>
          ventasPorIDUbicacion[b]!.compareTo(ventasPorIDUbicacion[a]!));
    // Tomamos las primeras 5 ubicaciones con mayores ventas
    sortedSucursales = sortedSucursales.take(5).toList();

    List<BarChartGroupData> listaBarChartData = List.generate(
      sortedSucursales.length,
      (index) {
        final idUbicacion = sortedSucursales[index];
        final ventas = ventasPorIDUbicacion[idUbicacion]!;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: ventas, // Usamos el valor de ventas directamente
              color: Colors.blue,
              width: 35,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY:
                    maxSales, // Usamos el valor máximo solo para la última barra
                color: Colors.grey[300],
              ),
            ),
          ],
        );
      },
    );

    return listaBarChartData;
  }

  double calcularSumaVentaNetaTotal() {
    final datosFiltrados =
        filtrarDatosPorSucursalTabla(datosC1, selectedSucursal);
    return datosFiltrados.fold<double>(0, (previousValue, element) {
      return previousValue +
          (double.tryParse(element['venta_neta'] ?? '0.0') ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM', 'es_MX').format(DateTime.now());

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
                    name: nombre,
                    profession: empresa,
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
                        'Seleccionar Sucursal',
                        style: TextStyle(color: Colors.white),
                      ),
                      children: sucursalesOptions.map((sucursal) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedSucursal = sucursal;
                              // calcularTotalventas(); // Reemplazar con el método correcto si es necesario
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Venta forma de',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'pago (consolidada)',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
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
                    ).format(calcularSumaVentaNetaTotal())}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Gráfica de ventas por forma de pago
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: SalesBarChart(
                      convertirDatosAVentasBarChart(datosC1,
                          selectedSucursal), // Pasamos la sucursal seleccionada a la función
                      datosC1
                          .map((dato) => dato['ubicacion'].toString())
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: CustomDataTable(
                        columns: const [
                          DataColumn(label: Text('Ubicación')),
                          DataColumn(label: Text('Sucursal')),
                          DataColumn(label: Text('Forma de Pago')),
                          DataColumn(label: Text('Venta')),
                          DataColumn(label: Text('Venta Neta')),
                        ],
                        rows: datosC1
                            .map((datos) => DataRow(
                                  cells: [
                                    DataCell(Text(datos['ubicacion'] ?? '')),
                                    DataCell(Text(datos['nombre'] ?? '')),
                                    DataCell(Text(datos['Forma_pago'] ?? '')),
                                    DataCell(Text(datos['venta'] ?? '')),
                                    DataCell(Text(datos['venta_neta'] ?? '')),
                                  ],
                                ))
                            .toList(),
                        footerRows: [
                          DataRow(cells: [
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            const DataCell(Text('Total:')),
                            DataCell(Text(totalVenta.toString())),
                            DataCell(Text(totalVentaNeta.toString())),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Map<String, String> sucursalesMap = {};
