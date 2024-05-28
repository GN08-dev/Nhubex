import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:intl/intl.dart';

class Prueba extends StatefulWidget {
  const Prueba({Key? key});

  @override
  State<Prueba> createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  bool loading = false;
  List<Map<String, String>> unionParametros = [];
  Map<String, String> sucursalesMap = {};
  String selectedSucursal = 'Todas las sucursales';
  List<String> sucursalesOptions = ['Todas las sucursales'];
  int currentPage = 0;
  int rowsPerPage = 5;

  @override
  void initState() {
    super.initState();
    obtenerDatos();
  }

  Future<void> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_consolidada&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22shernandez%22,%22fini%22:%222024-05-19%22,%22ffin%22:%222024-05-19%22%7D%7D&format=JSON&isFront=true';
    try {
      final response = await Dio().get(url);
      print('URL: $url');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);

        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        unionParametros.clear();
        for (var item in c1Data) {
          Map<String, String> paramMap = {};
          item.forEach((key, value) {
            paramMap[key.toLowerCase()] = value.toString();
          });
          unionParametros.add(paramMap);
        }

        unionParametros.sort((a, b) {
          double ventaNetaA = double.tryParse(a['venta_neta'] ?? '0') ?? 0;
          double ventaNetaB = double.tryParse(b['venta_neta'] ?? '0') ?? 0;
          return ventaNetaB.compareTo(ventaNetaA);
        });

        for (var dato in unionParametros) {
          String nombreSucursal = dato['nombre'] ?? '';
          String ubicacion = dato['ubicacion'] ?? '';
          sucursalesMap[nombreSucursal] = ubicacion;
        }

        setState(() {
          sucursalesOptions.addAll(sucursalesMap.keys.toList());
          if (sucursalesOptions.isNotEmpty) {
            selectedSucursal = sucursalesOptions.first;
          }
        });
      } else {
        mostrarError(
            'Error al obtener los datos. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      mostrarError('Error al cargar datos');
      print('URL: $url');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  String calcularTotal(String columna) {
    double total = 0.0;
    for (var param in unionParametros) {
      if (param['nombre'] == selectedSucursal ||
          selectedSucursal == 'Todas las sucursales') {
        double valor = double.tryParse(param[columna] ?? '0.0') ?? 0.0;
        total += valor;
      }
    }
    return total.toStringAsFixed(2);
  }

  String formatNumber(String value) {
    double numericValue = double.tryParse(value) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      height: 400,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              CustomDataTable(
                                columns: const [
                                  DataColumn(
                                    label: Text('Ubicacion'),
                                  ),
                                  DataColumn(
                                    label: Text('Nombre'),
                                  ),
                                  DataColumn(
                                    label: Text('Venta Neta'),
                                  ),
                                  DataColumn(
                                    label: Text('Devolucion'),
                                  ),
                                  DataColumn(
                                    label: Text('Ventas Menos devolucion'),
                                  ),
                                  DataColumn(
                                    label: Text('Venta sin impuesto'),
                                  ),
                                  DataColumn(
                                    label: Text('Impuestos'),
                                  ),
                                  DataColumn(
                                    label: Text('Tickets'),
                                  ),
                                  DataColumn(
                                    label: Text('Promedio Tickets'),
                                  ),
                                  DataColumn(
                                    label: Text('Piezas'),
                                  ),
                                ],
                                rows: unionParametros
                                    .where((param) =>
                                        param['nombre'] == selectedSucursal ||
                                        selectedSucursal ==
                                            'Todas las sucursales')
                                    .skip(currentPage * rowsPerPage)
                                    .take(rowsPerPage)
                                    .map((param) {
                                  double tickets = double.tryParse(
                                          param['tickets'] ?? '0.0') ??
                                      0.0;
                                  double ventas = double.tryParse(
                                          param['venta_neta'] ?? '0.0') ??
                                      0.0;
                                  double promedioTickets =
                                      tickets != 0.0 ? ventas / tickets : 0.0;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(param['ubicacion'] ?? ''),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(param['nombre'] ?? ''),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(
                                            formatNumber(
                                                param['venta_neta'] ?? ''),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(formatNumber(
                                              param['devoluciones'] ?? '')),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(formatNumber(
                                              param['ventasmenosdev'] ?? '')),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(formatNumber(
                                              param['venta'] ?? '')),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(formatNumber(
                                              param['impuestos'] ?? '')),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(formatNumber(
                                              param['tickets'] ?? '')),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(formatNumber(
                                              promedioTickets.toString())),
                                        ),
                                      ),
                                      DataCell(
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 12.0),
                                          child: Text(formatNumber(
                                              param['piezas'] ?? '')),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                footerRows: [
                                  DataRow(cells: [
                                    const DataCell(Text('')),
                                    const DataCell(Text('Total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataCell(
                                      Text(
                                        formatNumber(
                                            calcularTotal('venta_neta')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        formatNumber(
                                            calcularTotal('devoluciones')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        formatNumber(
                                            calcularTotal('ventasmenosdev')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        formatNumber(calcularTotal('venta')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        formatNumber(
                                            calcularTotal('impuestos')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        formatNumber(calcularTotal('tickets')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const DataCell(Text('')),
                                    DataCell(
                                      Text(
                                        formatNumber(calcularTotal('piezas')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: currentPage > 0
                                        ? () {
                                            setState(() {
                                              currentPage--;
                                            });
                                          }
                                        : null,
                                    child: const Text('Anterior'),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: (currentPage + 1) * rowsPerPage <
                                            unionParametros.length
                                        ? () {
                                            setState(() {
                                              currentPage++;
                                            });
                                          }
                                        : null,
                                    child: const Text('Siguiente'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
