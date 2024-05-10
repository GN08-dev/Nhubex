import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/info_card.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/redireccionamiento.dart';

class Prueba extends StatefulWidget {
  const Prueba({Key? key}) : super(key: key);

  @override
  State<Prueba> createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
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

  @override
  void initState() {
    super.initState();
    obtenerNombreUsuario();
    obtenerRolUsuario();
    obtenerNombreEmpresa();
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
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_detalle_forma_pago&attributes=%7B%22DATOS%22:%7B%22uactivo%22:%22shernandez%22,%22fini%22:%222024-04-25%22,%22ffin%22:%222024-04-25%22%7D%7D&format=JSON&isFront=true';

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

    for (var item in datosC1) {
      String ubicacion = item['ubicacion'] as String;
      String nombre = item['nombre'] as String;
      String formaPago = item['desc_fp'] as String;
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

//datos
  // Función para obtener el nombre de la empresa
  Future<void> obtenerNombreEmpresa() async {
    String nombreEmpresa = await MenuHelper.obtenerNombreEmpresa();
    setState(() {
      empresa = nombreEmpresa;
    });
  }

  // Función para obtener el nombre del usuario
  Future<void> obtenerNombreUsuario() async {
    String nombre = await MenuHelper.obtenerNombreUsuario();
    setState(() {
      nombreUsuario = nombre;
    });
  }

  // Función para obtener el rol del usuario
  Future<void> obtenerRolUsuario() async {
    String rol = await MenuHelper.obtenerRolUsuario();
    setState(() {
      rolUsuario = rol;
    });
  }

  @override
  Widget build(BuildContext context) {
    formasDePago =
        datosC1.map((item) => item['desc_fp'] as String).toSet().toList();

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
                      children: nombres.map((nombre) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedName = nombre;
                              obtenerTotalVentasPorSucursalYFormaPago();
                            });
                          },
                          child: Container(
                            color: Colors.black26,
                            child: ListTile(
                              title: Text(
                                nombre,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    ExpansionTile(
                      title: Text(
                        'Tipos venta',
                        style: TextStyle(color: Colors.white),
                      ),
                      children: [
                        ListTile(
                          title: Text(
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
                          title: Text(
                            'Venta',
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
            Text('Venta por forma', style: TextStyle(fontSize: 18)),
            Text('De pago', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: MediaQuery.of(context).size.width,
              height: 400,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                                  DataCell(Text(nombres.firstWhere((nombre) =>
                                      datosC1.any((item) =>
                                          item['ubicacion'] == entry.key &&
                                          item['nombre'] == nombre)))),
                                  for (var formaPago in formasDePago)
                                    DataCell(Text(
                                      '${entry.value[formaPago] != null ? entry.value[formaPago]?.toStringAsFixed(2) : "0.00"}',
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            for (var formaPago in formasDePago)
                              DataCell(
                                Text(
                                  // ignore: unnecessary_string_interpolations
                                  '${totalVentaGeneral()[formaPago]?.toStringAsFixed(2) ?? "0.00"}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/*const SizedBox(height: 20),
                    const Text('Total Venta General',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ...totalVentaGeneral().entries.map(
                          (total) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(total.key),
                              Text(total.value.toStringAsFixed(2)),
                            ],
                          ),
                        ),*/
