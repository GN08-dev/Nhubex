import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';

//rep_venta_consolidada //Venta por Ticket (Detalle)
class Ventaporticketdetalle extends StatefulWidget {
  const Ventaporticketdetalle({super.key});

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

  @override
  void initState() {
    super.initState();
    obtenerNombreEmpresa();
    obtenerNombreUsuario().then((_) {
      if (nombre.isNotEmpty) {
        // Llama a la función obtenerDatos en segundo plano
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
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_ticket_detalle&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombre%22,%22fini%22:%222024-04-19%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        // Procesa y almacena los datos recibidos en `datosC1`
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
    final startIndex = (pagina - 1) * itemsPorPagina;
    final endIndex = startIndex + itemsPorPagina;
    return datosC1.sublist(
        startIndex, endIndex < datosC1.length ? endIndex : datosC1.length);
  }

  //grafica proximante

  @override
  Widget build(BuildContext context) {
    final paginasTotales = (datosC1.length / itemsPorPagina).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas Ticket'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
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
                                    DataCell(Text(datos['ubicacion'] ?? '')),
                                    DataCell(Text(datos['nombre'] ?? '')),
                                    DataCell(Text(datos['Ticket'] ?? '')),
                                    DataCell(Text(datos['CODIGOBARRAS'] ?? '')),
                                    DataCell(Text(datos['Piezas'] ?? '')),
                                    DataCell(Text(datos['PRECIO_UNIT'] ?? '')),
                                    DataCell(Text(datos['PRECIO_TOTAL'] ?? '')),
                                    DataCell(Text(datos['Impuestos'] ?? '')),
                                    DataCell(Text(datos['SUBTOTAL'] ?? '')),
                                    DataCell(Text(datos['Venta'] ?? '')),
                                    DataCell(Text(datos['Venta_Neta'] ?? '')),
                                    DataCell(Text(datos['Factura'] ?? '')),
                                    DataCell(Text(datos['costo'] ?? '')),
                                    DataCell(Text(datos['Vendedor'] ?? '')),
                                  ],
                                ))
                            .toList(),
                        footerRows: [],
                      ),
                    ),
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
                            icon: Icon(Icons.arrow_back),
                          ),
                        Text('Página $paginaActual de $paginasTotales'),
                        if (paginaActual < paginasTotales)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                paginaActual++;
                              });
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
