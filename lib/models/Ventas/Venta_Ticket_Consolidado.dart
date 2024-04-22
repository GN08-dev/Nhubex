import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_proyect/design/kit_de_estilos/graficas/graphbar.dart'; // Importamos la clase SalesBarChart

class VentaTicketConsolidado extends StatefulWidget {
  const VentaTicketConsolidado({Key? key}) : super(key: key);

  @override
  State<VentaTicketConsolidado> createState() => _VentaTicketConsolidadoState();
}

class _VentaTicketConsolidadoState extends State<VentaTicketConsolidado> {
  String empresa = '';
  String nombre = '';
  bool loading = false;
  double sumaVentaNetaTotal = 0.0;
  List<Map<String, dynamic>> datosC1 = [];
  Map<String, String> sucursalesMap = {};
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

  //pagina
  int itemsPorPagina = 5;
  int paginaActual = 1;

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
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_ticket_consolidado&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%2211%22,%22uactivo%22:%22$nombre%22,%22fini%22:%222024-04-18%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        List<Map<String, dynamic>> datos = [];
        for (var item in c1Data) {
          // Convertir los datos del JSON a minúsculas
          Map<String, dynamic> lowerCaseData = {};
          item.forEach((key, value) {
            lowerCaseData[key.toLowerCase()] = value;
          });
          datos.add(lowerCaseData);
        }
        // Obtener nombres de sucursales y sus ubicaciones
        for (var dato in datos) {
          String nombreSucursal = dato['nombre'] ?? '';
          String ubicacion = dato['ubicacion'] ?? '';
          sucursalesMap[nombreSucursal] = ubicacion;
        }

        // Calcular los totales
        double totalVenta = 0;
        double totalVentaNeta = 0;
        double totalImpuestos = 0;
        double totalTickets = 0;

        for (var registro in datos) {
          totalVenta += double.tryParse(registro['venta'] ?? '0.0') ?? 0.0;
          totalVentaNeta +=
              double.tryParse(registro['venta_neta'] ?? '0.0') ?? 0.0;

          totalImpuestos +=
              double.tryParse(registro['impuestos'] ?? '0.0') ?? 0.0;
          totalTickets += double.tryParse(registro['ticket'] ?? '0.0') ?? 0.0;
        }

        setState(() {
          totalTicketsTotal = totalTickets;
          totalImpuestosTotal = totalImpuestos;
          totalVentaTotal = totalVenta;
          totalVentaNetaTotal = totalVentaNeta;
        });

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

  List<BarChartGroupData> convertirDatosAVentasBarChart(List<dynamic> datos) {
    Map<String, double> ventasPorIDUbicacion = {};

    for (var registro in datos) {
      String idUbicacion = registro['ubicacion'].toString();
      double valor = double.tryParse(registro['venta_neta'] ?? '0.0') ?? 0.0;
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

  ///CALCULAR TOTALES
  double totalTicketsTotal = 0;
  double totalImpuestosTotal = 0;
  double totalVentaTotal = 0;
  double totalVentaNetaTotal = 0;

  void calcularEstadisticas() {
    sumaVentaNetaTotal = datosC1.fold<double>(0, (previousValue, element) {
      return previousValue +
          (double.tryParse(element['venta_neta'] ?? '0.0') ?? 0.0);
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
              'Venta por ticket',
              style: TextStyle(fontSize: 18), // Ajusta el tamaño del subtítulo
            ),
            Text(
              '(consolidado)',
              style: TextStyle(fontSize: 16), // Ajusta el tamaño del subtítulo
            )
          ],
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
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
                  ).format(sumaVentaNetaTotal)}', //me falta el campo del total venta neta
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 500,
                    child: SalesBarChart(
                      convertirDatosAVentasBarChart(datosC1),
                      datosC1
                          .map((dato) => dato['ubicacion'].toString())
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: CustomDataTable(
                        columns: const [
                          DataColumn(label: Text('Ubicación')),
                          DataColumn(label: Text('Sucursal')),
                          DataColumn(label: Text('Vendedor')),
                          DataColumn(label: Text('Ticket')),
                          DataColumn(label: Text('Impuestos')),
                          DataColumn(label: Text('Venta')),
                          DataColumn(label: Text('Venta Neta')),
                        ],
                        rows: getDatosPagina(paginaActual)
                            .map(
                              (dato) => DataRow(
                                cells: [
                                  DataCell(Text(dato['ubicacion'].toString())),
                                  DataCell(Text(dato['nombre'].toString())),
                                  DataCell(Text(dato['vendedor'].toString())),
                                  DataCell(Text(dato['ticket'].toString())),
                                  DataCell(Text(
                                    '${NumberFormat("#,##0.00").format(double.parse(dato['impuestos'].toString()))}', // Aplica el formato con coma para miles
                                  )),
                                  DataCell(Text(
                                    '${NumberFormat("#,##0.00").format(double.parse(dato['venta'].toString()))}', // Aplica el formato con coma para miles
                                  )),
                                  DataCell(Text(
                                    '${NumberFormat("#,##0.00").format(double.parse(dato['venta_neta'].toString()))}', // Aplica el formato con coma para miles
                                  )),
                                ],
                              ),
                            )
                            .toList(),
                        footerRows: [
                          DataRow(cells: [
                            const DataCell(Text('')),
                            const DataCell(Text('')),
                            const DataCell(Text('Totales')),
                            DataCell(Text(
                              '${NumberFormat("#,##0.00").format(totalTicketsTotal)}', // Aplica el formato con coma para miles
                              style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold), // Estilo en negritas para el footer
                            )),
                            DataCell(Text(
                              '${NumberFormat("#,##0.00").format(totalImpuestosTotal)}', // Aplica el formato con coma para miles
                              style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold), // Estilo en negritas para el footer
                            )),
                            DataCell(Text(
                              '${NumberFormat("#,##0.00").format(totalVentaTotal)}', // Aplica el formato con coma para miles
                              style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold), // Estilo en negritas para el footer
                            )),
                            DataCell(Text(
                              '${NumberFormat("#,##0.00").format(totalVentaNetaTotal)}', // Aplica el formato con coma para miles
                              style: TextStyle(
                                  fontWeight: FontWeight
                                      .bold), // Estilo en negritas para el footer
                            )),
                          ])
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
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
                ),
              ],
            ),
    );
  }
}
