import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/redireccionamiento.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:flutter_proyect/models/Ventas/Graficas/GraficaDePastelDeForma_pagoDetalle.dart';
import 'package:intl/intl.dart';

class VentaFormaPagoConsolidada extends StatefulWidget {
  const VentaFormaPagoConsolidada({super.key});

  @override
  State<VentaFormaPagoConsolidada> createState() =>
      _VentaFormaPagoConsolidadaState();
}

class _VentaFormaPagoConsolidadaState extends State<VentaFormaPagoConsolidada> {
  bool loading = false;
  List<Map<String, dynamic>> datosC1 = [];
  List<String> formasDePago = [];
  List<String> nombres = [];
  Map<String, Map<String, double>> ventasPorSucursalYFormaPago = {};
  String selectedSumType = 'venta_neta';
  String? selectedName;
  String empresa = '';
  String nombreUsuario = '';
  String rolUsuario = '';
  String empresaSiglas = '';
  String prueba = 've';
  String fecha =
      '2024-04-25'; //DateFormat('yyyy-MM-dd').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    obtenerNombreUsuario();
    obtenerRolUsuario();
    obtenerNombreEmpresa();
    obtenerSiglasEmpresa();
    obtenerDatos().then((data) {
      setState(() {
        datosC1 = data;
        obtenerTotalVentasPorSucursalYFormaPago();
      });
    }).catchError((error) {
      mostrarError('Error al cargar los datos: $error');
    });
  }

  Future<List<Map<String, dynamic>>> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_consolidada_forma_pago&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombreUsuario%22,%22fini%22:%222024-04-18%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];
        return List<Map<String, dynamic>>.from(c1Data);
      } else {
        throw 'Error al obtener los datos del JSON. Código de estado: ${response.statusCode}';
      }
    } catch (e) {
      print('Error: $e');
      throw 'Error al cargar los datos.';
    } finally {
      setState(() => loading = false);
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void obtenerTotalVentasPorSucursalYFormaPago() {
    // Limpiar datos existentes al cambiar la forma de sumatoria seleccionada
    ventasPorSucursalYFormaPago.clear();
    nombres.clear();

    // Filtrar los datos por el nombre de la sucursal seleccionada
    List<Map<String, dynamic>> datosFiltrados = selectedName != null
        ? datosC1.where((item) => item['nombre'] == selectedName).toList()
        : datosC1;

    for (var item in datosFiltrados) {
      String ubicacion = item['ubicacion'] as String;
      String nombre = item['nombre'] as String;
      String formaPago = item['Forma_pago'] as String;
      double venta = selectedSumType == 'venta_neta'
          ? double.parse(item['venta_neta'] as String)
          : double.parse(item['venta'] as String);

      ventasPorSucursalYFormaPago[ubicacion] ??= {};
      ventasPorSucursalYFormaPago[ubicacion]![formaPago] ??= 0.0;
      ventasPorSucursalYFormaPago[ubicacion]![formaPago] =
          (ventasPorSucursalYFormaPago[ubicacion]![formaPago] ?? 0.0) + venta;

      if (!nombres.contains(nombre)) {
        nombres.add(nombre);
      }
    }
  }

  Map<String, double> totalVentaGeneral() {
    Map<String, double> totalVentas = {};

    formasDePago.forEach((formaPago) {
      double total = 0.0;
      ventasPorSucursalYFormaPago.values.forEach((sucursalVentas) {
        if (sucursalVentas.containsKey(formaPago)) {
          total += sucursalVentas[formaPago]!;
        }
      });
      totalVentas[formaPago] = total;
    });

    return totalVentas;
  }

  double calcularVentaTotalNetaGeneral() {
    double total = 0.0;

    // Iterar sobre todas las ventas por ubicación y forma de pago
    ventasPorSucursalYFormaPago.values.forEach((sucursalVentas) {
      sucursalVentas.values.forEach((venta) {
        total += venta;
      });
    });

    return total;
  }

  Future<void> obtenerNombreEmpresa() async {
    String nombreEmpresa = await MenuHelper.obtenerNombreEmpresa();
    setState(() {
      empresa = nombreEmpresa;
    });
  }

  Future<void> obtenerNombreUsuario() async {
    String nombre = await MenuHelper.obtenerNombreUsuario();
    setState(() {
      nombreUsuario = nombre;
    });
  }

  Future<void> obtenerRolUsuario() async {
    String rol = await MenuHelper.obtenerRolUsuario();
    setState(() {
      rolUsuario = rol;
    });
  }

  Future<void> obtenerSiglasEmpresa() async {
    String siglas = await MenuHelper.obtenersiglasEmpresa();
    setState(() {
      empresaSiglas = siglas;
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM', 'es_MX').format(DateTime.now());
    formasDePago =
        datosC1.map((item) => item['Forma_pago'] as String).toSet().toList();

    return Scaffold(
      endDrawer: Drawer(
        child: Column(
          children: [
            Container(
              color: const Color.fromRGBO(0, 184, 239, 1),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  InfoCard(
                    name: nombreUsuario,
                    profession: empresa,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color.fromRGBO(46, 48, 53, 1),
                child: ListView(
                  children: [
                    ExpansionTile(
                      title: const Text(
                        'Seleccionar Sucursal',
                        style: TextStyle(color: Colors.white),
                      ),
                      children: [
                        ListTile(
                          title: const Text(
                            'Todas las sucursales',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              selectedName = null;
                              obtenerTotalVentasPorSucursalYFormaPago();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        for (var nombre in nombres)
                          ListTile(
                            title: Text(
                              nombre,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              setState(() {
                                selectedName = nombre;
                                obtenerTotalVentasPorSucursalYFormaPago();
                              });
                            },
                          ),
                      ],
                    ),
                    ExpansionTile(
                      title: const Text(
                        'Tipos venta',
                        style: TextStyle(color: Colors.white),
                      ),
                      children: [
                        ListTile(
                          title: const Text(
                            'Venta Neta',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              selectedSumType = 'venta_neta';
                              obtenerTotalVentasPorSucursalYFormaPago();
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: const Text(
                            'Venta sin impuesto',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              selectedSumType = 'venta';
                              obtenerTotalVentasPorSucursalYFormaPago();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
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
              'Venta por forma',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'De pago',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
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
                        '\$${NumberFormat("#,##0.00").format(calcularVentaTotalNetaGeneral())}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context)
                            .size
                            .width, // Ancho de la pantalla
                        child: Padding(
                          padding: const EdgeInsets.all(
                              16.0), // Ajusta según necesites
                          child: GreaficaDePastel(
                            totalVentaGeneral: totalVentaGeneral(),
                            formasDePago: formasDePago,
                          ),
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
                              columns: [
                                const DataColumn(label: Text('Ubicacion')),
                                const DataColumn(label: Text('Nombre')),
                                for (var formaPago in formasDePago)
                                  DataColumn(label: Text(formaPago)),
                              ],
                              rows: ventasPorSucursalYFormaPago.entries
                                  .map((entry) => DataRow(cells: [
                                        DataCell(Text(entry.key)), // Ubicación
                                        DataCell(Text(nombres.firstWhere(
                                            (nombre) => datosC1.any((item) =>
                                                item['ubicacion'] ==
                                                    entry.key &&
                                                item['nombre'] == nombre)))),
                                        for (var formaPago in formasDePago)
                                          DataCell(Text(
                                            '${entry.value[formaPago] != null ? NumberFormat("#,##0.00").format(entry.value[formaPago]!) : "0.00"}',
                                          )),
                                      ]))
                                  .toList(),
                              footerRows: [
                                DataRow(cells: [
                                  const DataCell(
                                    Text(''),
                                  ),
                                  const DataCell(
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  for (var formaPago in formasDePago)
                                    DataCell(
                                      Text(
                                        // ignore: unnecessary_string_interpolations
                                        '${totalVentaGeneral()[formaPago] != null ? NumberFormat("#,##0.00").format(totalVentaGeneral()[formaPago]!) : "0.00"}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
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
