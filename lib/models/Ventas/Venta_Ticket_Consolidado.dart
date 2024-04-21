import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Graficas/graphbar.dart'; // Importamos la clase SalesBarChart

class VentaTicketConsolidado extends StatefulWidget {
  const VentaTicketConsolidado({Key? key}) : super(key: key);

  @override
  State<VentaTicketConsolidado> createState() => _VentaTicketConsolidadoState();
}

class _VentaTicketConsolidadoState extends State<VentaTicketConsolidado> {
  String empresa = '';
  String nombre = '';
  bool loading = false;
  List<Map<String, dynamic>> datosC1 = [];

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
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_ticket_consolidado&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%2211%22,%22uactivo%22:%22$nombre%22,%22fini%22:%222024-04-18%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

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

  List<BarChartGroupData> convertirDatosAVentasBarChart(List<dynamic> datos) {
    Map<String, double> ventasPorIDUbicacion = {};
    double totalVentaNeta = 0;

    for (var registro in datos) {
      String idUbicacion = registro['ubicacion'].toString();
      double valor = double.tryParse(registro['Venta_Neta'] ?? '0.0') ?? 0.0;
      ventasPorIDUbicacion[idUbicacion] =
          (ventasPorIDUbicacion[idUbicacion] ?? 0) + valor;
      totalVentaNeta += valor;
    }

    // Redondear totalVentaNeta hacia arriba a la centena más cercana
    double maxSales = (totalVentaNeta.ceilToDouble() / 100000).ceil() * 100000;

    List<String> sortedSucursales = ventasPorIDUbicacion.keys.toList()
      ..sort((a, b) =>
          ventasPorIDUbicacion[b]!.compareTo(ventasPorIDUbicacion[a]!));

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

    return listaBarChartData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(),
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
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 300,
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
                          DataColumn(label: Text('Ticket')),
                          DataColumn(label: Text('Venta')),
                          DataColumn(label: Text('Venta Neta')),
                        ],
                        rows: datosC1
                            .map(
                              (dato) => DataRow(
                                cells: [
                                  DataCell(Text(dato['ubicacion'].toString())),
                                  DataCell(Text(dato['nombre'].toString())),
                                  DataCell(Text(dato['Ticket'].toString())),
                                  DataCell(Text(dato['Venta'].toString())),
                                  DataCell(Text(dato['Venta_Neta'].toString())),
                                ],
                              ),
                            )
                            .toList(),
                        footerRows: [],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
