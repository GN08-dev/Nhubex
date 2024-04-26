import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class Prueba extends StatefulWidget {
  const Prueba({Key? key}) : super(key: key);

  @override
  State<Prueba> createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  String nombreUsuario = '';
  String nombreEmpresa = '';
  bool loading = false;
  List<Map<String, dynamic>> datosC1 = [];
  Map<String, Map<String, dynamic>> sucursalesData = {};
  String selectedSucursal = 'Sucursal';
  List<String> sucursales = ['Sucursal'];

  double totalEfectivoVenta = 0.0;
  double totalEfectivoVentaNeta = 0.0;
  double totalTdcVenta = 0.0;
  double totalTdcVentaNeta = 0.0;
  double totalTddVenta = 0.0;
  double totalTddVentaNeta = 0.0;
  double totalTickets = 0;

  @override
  void initState() {
    super.initState();
    obtenerNombreEmpresa();
    obtenerNombreUsuario().then((_) {
      if (nombreUsuario.isNotEmpty) {
        obtenerDatos().then((data) {
          setState(() {
            datosC1 = data;
            reorganizarDatos();
            calcularTotalesPorFormaDePago();
            calcularTotalesGeneral();
            obtenerSucursales();
          });
        });
      } else {
        mostrarError('Nombre de usuario no cargado.');
      }
    });
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

  Future<List<Map<String, dynamic>>> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_detalle_forma_pago&attributes=%7B%22DATOS%22:%7B%22uactivo%22:%22$nombreUsuario%22,%22fini%22:%222024-04-18%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];
        return List<Map<String, dynamic>>.from(c1Data);
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

  void reorganizarDatos() {
    sucursalesData.clear();
    for (var dato in datosC1) {
      final ubicacion = dato['ubicacion'];
      final nombre = dato['nombre'];
      final descFp = dato['desc_fp'];
      final venta = double.tryParse(dato['venta'] ?? '0') ?? 0.0;
      final ventaNeta = double.tryParse(dato['venta_neta'] ?? '0.0') ?? 0.0;
      // ignore: unused_local_variable
      final ticket = dato['ticket'];

      final key = '$ubicacion-$nombre';
      sucursalesData.putIfAbsent(
          key,
          () => {
                'ubicacion': ubicacion,
                'nombre': nombre,
                'EFECTIVO_VENTA': 0.0,
                'EFECTIVO_VENTA_NETA': 0.0,
                'TDC_VENTA': 0.0,
                'TDC_VENTA_NETA': 0.0,
                'TDD_VENTA': 0.0,
                'TDD_VENTA_NETA': 0.0,
                'TICKET_TOTAL': 0,
              });

      if (descFp.trim() == 'EFECTIVO') {
        sucursalesData[key]?['EFECTIVO_VENTA'] += venta;
        sucursalesData[key]?['EFECTIVO_VENTA_NETA'] += ventaNeta;
      } else if (descFp.trim() == 'TDD') {
        sucursalesData[key]?['TDD_VENTA'] += venta;
        sucursalesData[key]?['TDD_VENTA_NETA'] += ventaNeta;
      } else if (descFp.trim() == 'TDC') {
        sucursalesData[key]?['TDC_VENTA'] += venta;
        sucursalesData[key]?['TDC_VENTA_NETA'] += ventaNeta;
      }

      sucursalesData[key]?['TICKET_TOTAL']++;
    }
  }

  void calcularTotalesPorFormaDePago() {
    for (var key in sucursalesData.keys) {
      final data = sucursalesData[key];
      final efectivoVenta = data?['EFECTIVO_VENTA'];
      final efectivoVentaNeta = data?['EFECTIVO_VENTA_NETA'];
      final tdcVenta = data?['TDC_VENTA'];
      final tdcVentaNeta = data?['TDC_VENTA_NETA'];
      final tddVenta = data?['TDD_VENTA'];
      final tddVentaNeta = data?['TDD_VENTA_NETA'];

      print(
          'Ubicación: ${data?['ubicacion']}, Nombre: ${data?['nombre']}, EFECTIVO_VENTA: $efectivoVenta, EFECTIVO_VENTA NETA: $efectivoVentaNeta, TDC_VENTA: $tdcVenta, TDC_VENTA NETA: $tdcVentaNeta, TDD_VENTA: $tddVenta, TDD_VENTA NETA: $tddVentaNeta');
    }
  }

  void calcularTotalesGeneral() {
    totalEfectivoVenta = 0.0;
    totalEfectivoVentaNeta = 0.0;
    totalTdcVenta = 0.0;
    totalTdcVentaNeta = 0.0;
    totalTddVenta = 0.0;
    totalTddVentaNeta = 0.0;
    totalTickets = 0;

    for (var key in sucursalesData.keys) {
      final data = sucursalesData[key];
      totalEfectivoVenta += data?['EFECTIVO_VENTA'] ?? 0.0;
      totalEfectivoVentaNeta += data?['EFECTIVO_VENTA_NETA'] ?? 0.0;
      totalTdcVenta += data?['TDC_VENTA'] ?? 0.0;
      totalTdcVentaNeta += data?['TDC_VENTA_NETA'] ?? 0.0;
      totalTddVenta += data?['TDD_VENTA'] ?? 0.0;
      totalTddVentaNeta += data?['TDD_VENTA_NETA'] ?? 0.0;
      totalTickets += data?['TICKET_TOTAL'] ?? 0;
    }

    print('Totales generales:');
    print('EFECTIVO_VENTA: $totalEfectivoVenta');
    print('EFECTIVO_VENTA NETA: $totalEfectivoVentaNeta');
    print('TDC_VENTA: $totalTdcVenta');
    print('TDC_VENTA NETA: $totalTdcVentaNeta');
    print('TDD_VENTA: $totalTddVenta');
    print('TDD_VENTA NETA: $totalTddVentaNeta');
    print('TICKET_TOTAL: $totalTickets');
  }

  void obtenerSucursales() {
    for (var dato in datosC1) {
      final nombreSucursal = dato['nombre'] as String;
      if (!sucursales.contains(nombreSucursal)) {
        sucursales.add(nombreSucursal);
      }
    }
    setState(() {
      selectedSucursal = 'Sucursal';
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM', 'es_MX').format(DateTime.now());

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: MediaQuery.of(context)
                      .size
                      .width, // Limita la anchura al ancho de la pantalla
                  child: Column(
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
                        ).format(totalEfectivoVentaNeta)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 100),
                      Container(
                        height: 300,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: CustomDataTable(
                              columns: const [
                                DataColumn(label: Text('Ubicación')),
                                DataColumn(label: Text('Nombre')),
                                //DataColumn(label: Text('Efectivo Venta')),
                                DataColumn(label: Text('Efectivo')),
                                //DataColumn(label: Text('TDC Venta')),
                                DataColumn(label: Text('TDC')),
                                //DataColumn(label: Text('TDD Venta')),
                                DataColumn(label: Text('TDD')),
                                DataColumn(label: Text('TICKET')),
                              ],
                              rows: sucursalesData.values.map<DataRow>((data) {
                                return DataRow(cells: [
                                  DataCell(Text(data['ubicacion'] ?? '')),
                                  DataCell(Text(data['nombre'] ?? '')),
                                  //DataCell(Text(NumberFormat("#,##0.00").format(data['EFECTIVO_VENTA']))),
                                  DataCell(Text(NumberFormat("#,##0.00")
                                      .format(data['EFECTIVO_VENTA_NETA']))),
                                  //DataCell(Text(NumberFormat("#,##0.00") .format(data['TDC_VENTA']))),
                                  DataCell(Text(NumberFormat("#,##0.00")
                                      .format(data['TDC_VENTA_NETA']))),
                                  //DataCell(Text(NumberFormat("#,##0.00").format(data['TDD_VENTA']))),
                                  DataCell(Text(NumberFormat("#,##0.00")
                                      .format(data['TDD_VENTA_NETA']))),
                                  DataCell(
                                      Text(data['TICKET_TOTAL'].toString())),
                                ]);
                              }).toList(),
                              footerRows: [
                                DataRow(cells: [
                                  const DataCell(Text(
                                    '',
                                  )),
                                  const DataCell(Text('Totales',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(
                                      NumberFormat("#,##0.00")
                                          .format(totalEfectivoVentaNeta),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(
                                      NumberFormat("#,##0.00")
                                          .format(totalTdcVentaNeta),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(
                                      NumberFormat("#,##0.00")
                                          .format(totalTddVentaNeta),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(totalTickets.toStringAsFixed(0),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold))),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
