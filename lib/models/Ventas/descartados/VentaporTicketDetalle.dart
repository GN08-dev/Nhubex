import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Graficas/graphbar.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';

class Ventaporticketdetalle extends StatefulWidget {
  const Ventaporticketdetalle({Key? key});

  @override
  State<Ventaporticketdetalle> createState() => _VentaporticketdetalleState();
}

class _VentaporticketdetalleState extends State<Ventaporticketdetalle> {
  String empresa = '';
  String nombre = '';
  bool loading = false;
  List<Map<String, dynamic>> datosC1 = [];
  int itemsPorPagina = 5;
  int paginaActual = 1;
  double sumaVentaNetaTotal = 0.0;
  Map<String, double> ventaNetaPorSucursal = {};
  String selectedSucursal = 'Todas las sucursales';
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
            calcularEstadisticas();
            calcularVentaNetaPorSucursal();
            actualizarListaSucursales();
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
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_ticket_detalle&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombre%22,%22fini%22:%222024-04-19%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        List<Map<String, dynamic>> datos = [];
        for (var item in c1Data) {
          datos.add(Map<String, dynamic>.from(item));
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

  List<Map<String, dynamic>> getDatosPagina(int pagina) {
    final datosFiltrados =
        filtrarDatosPorSucursalTabla(datosC1, selectedSucursal);
    final startIndex = (pagina - 1) * itemsPorPagina;
    final endIndex = startIndex + itemsPorPagina;
    final datosPagina = datosFiltrados.sublist(startIndex,
        endIndex < datosFiltrados.length ? endIndex : datosFiltrados.length);
    return datosPagina;
  }

  void calcularEstadisticas() {
    sumaVentaNetaTotal = datosC1.fold<double>(0, (previousValue, element) {
      return previousValue +
          (double.tryParse(element['Venta_Neta'] ?? '0.0') ?? 0.0);
    });
  }

  void calcularVentaNetaPorSucursal() {
    for (var item in datosC1) {
      final nombreSucursal = item['nombre'] as String;
      final ventaNeta = double.tryParse(item['Venta_Neta'] ?? '0.0') ?? 0.0;
      ventaNetaPorSucursal[nombreSucursal] =
          (ventaNetaPorSucursal[nombreSucursal] ?? 0) + ventaNeta;
    }
  }

  List<BarChartGroupData> convertirDatosAVentasBarChart(List<dynamic> datos) {
    Map<String, double> ventasPorIDUbicacion = {};

    for (var registro in datos) {
      String idUbicacion = registro['ubicacion'].toString();
      double valor = double.tryParse(registro['Venta_Neta'] ?? '0.0') ?? 0.0;
      ventasPorIDUbicacion[idUbicacion] =
          (ventasPorIDUbicacion[idUbicacion] ?? 0) + valor;
    }

    // Ordenamos las ubicaciones por ventas de mayor a menor
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

        // Si es la última ubicación, usamos el valor de ventas como máximo para el eje y
        // ignore: unused_local_variable
        double? maxY = index == sortedSucursales.length - 1 ? ventas : null;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: ventas, // Usamos el valor de ventas directamente
              color: Colors.blue,
              width: 35,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: ventas, // Usamos el valor máximo solo para la última barra
                color: Colors.grey[300],
              ),
            ),
          ],
        );
      },
    );

    return listaBarChartData;
  }

  List<String> obtenerUbicacionesUnicas(List<Map<String, dynamic>> datos) {
    Set<String> ubicaciones = Set();
    for (var dato in datos) {
      if (dato['ubicacion'] != null) {
        ubicaciones.add(dato['ubicacion'].toString());
      }
    }
    return ubicaciones.toList();
  }

  void actualizarListaSucursales() {
    Set<String> sucursales = Set();
    for (var dato in datosC1) {
      if (dato['nombre'] != null) {
        sucursales.add(dato['nombre'].toString());
      }
    }
    setState(() {
      sucursalesOptions.clear();
      sucursalesOptions.add('Todas las sucursales');
      sucursalesOptions.addAll(sucursales);
      selectedSucursal = 'Todas las sucursales';
    });
  }

  List<Map<String, dynamic>> filtrarDatosPorSucursal(
      List<Map<String, dynamic>> datos, String sucursal) {
    if (sucursal == 'Todas las sucursales') {
      return datos;
    } else {
      return datos.where((dato) => dato['nombre'] == sucursal).toList();
    }
  }

  double calcularSumaVentaNetaTotal() {
    final datosFiltrados =
        filtrarDatosPorSucursalTabla(datosC1, selectedSucursal);
    return datosFiltrados.fold<double>(0, (previousValue, element) {
      return previousValue +
          (double.tryParse(element['Venta_Neta'] ?? '0.0') ?? 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM', 'es_MX').format(DateTime.now());

    final datosFiltrados =
        filtrarDatosPorSucursalTabla(datosC1, selectedSucursal);
    final paginasTotales = (datosFiltrados.length / itemsPorPagina).ceil();
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
          children: [
            Text(
              'Ventas por ',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Ticket',
              style: TextStyle(fontSize: 16),
            )
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
                    const SizedBox(height: 50),
                    Container(
                      height: 300,
                      child: SalesBarChart(
                        convertirDatosAVentasBarChart(
                            filtrarDatosPorSucursal(datosC1, selectedSucursal)),
                        obtenerUbicacionesUnicas(
                            filtrarDatosPorSucursal(datosC1, selectedSucursal)),
                      ),
                    ),
                    Container(
                      height: 320,
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: CustomDataTable(
                            columns: const [
                              DataColumn(label: Text('Ubicación')),
                              DataColumn(label: Text('Sucursal')),
                              DataColumn(label: Text('Ticket')),
                              DataColumn(label: Text('Código de Barras')),
                              DataColumn(label: Text('Piezas')),
                              DataColumn(label: Text('Precio Unitario')),
                              DataColumn(label: Text('Precio Total')),
                              DataColumn(label: Text('Impuestos')),
                              DataColumn(label: Text('Subtotal')),
                              DataColumn(label: Text('Venta')),
                              DataColumn(label: Text('Venta Neta')),
                              DataColumn(label: Text('Factura')),
                              DataColumn(label: Text('Costo')),
                              DataColumn(label: Text('Vendedor')),
                            ],
                            rows: getDatosPagina(paginaActual)
                                .map((datos) => DataRow(
                                      cells: [
                                        DataCell(
                                            Text(datos['ubicacion'] ?? '')),
                                        DataCell(Text(datos['nombre'] ?? '')),
                                        DataCell(Text(datos['Ticket'] ?? '')),
                                        DataCell(
                                            Text(datos['CODIGOBARRAS'] ?? '')),
                                        DataCell(Text(datos['Piezas'] ?? '')),
                                        DataCell(
                                            Text(datos['PRECIO_UNIT'] ?? '')),
                                        DataCell(
                                            Text(datos['PRECIO_TOTAL'] ?? '')),
                                        DataCell(
                                            Text(datos['Impuestos'] ?? '')),
                                        DataCell(Text(datos['SUBTOTAL'] ?? '')),
                                        DataCell(Text(datos['Venta'] ?? '')),
                                        DataCell(
                                            Text(datos['Venta_Neta'] ?? '')),
                                        DataCell(Text(datos['Factura'] ?? '')),
                                        DataCell(Text(datos['costo'] ?? '')),
                                        DataCell(Text(datos['Vendedor'] ?? '')),
                                      ],
                                    ))
                                .toList(),
                            footerRows: [],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (paginaActual > 1)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                paginaActual--;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                          ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Página $paginaActual de $paginasTotales',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (paginaActual < paginasTotales)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                paginaActual++;
                              });
                            },
                            icon: const Icon(Icons.arrow_forward),
                          ),
                      ],
                    ),
                  ],
                )),
    );
  }
}
