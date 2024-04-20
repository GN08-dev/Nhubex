import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VentaConsilidada extends StatefulWidget {
  const VentaConsilidada({Key? key}) : super(key: key);
// rep_venta_consolidada //Venta Consolidada por Rango de Fechas
  @override
  State<VentaConsilidada> createState() => _VentaConsilidadaState();
}

class _VentaConsilidadaState extends State<VentaConsilidada> {
  String empresa = '';
  String nombre = '';

  bool loading = false;
  List<Map<String, String>> unionParametros = [];

  @override
  void initState() {
    super.initState();
    obtenerNombreEmpresa();
    obtenerNombreUsuario().then((_) {
      if (nombre.isNotEmpty) {
        obtenerDatos();
      } else {
        mostrarError('Nombre de usuario no cargado.');
      }
    });
  }

  Future<void> obtenerNombreUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('Nombre') ?? '';
    });
    print('Nombre cargado de SharedPreferences: $nombre');
  }

  Future<void> obtenerNombreEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      empresa = prefs.getString('Nombre_Empresa') ?? '';
    });
  }

  Future<void> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_consolidada&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombre%22,%22fini%22:%222024-04-19%22,%22ffin%22:%222024-04-20%22%7D%7D&format=JSON&isFront=true';
    try {
      final response = await Dio().get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        // Limpia y almacena los datos recibidos en unionParametros
        unionParametros.clear();
        for (var item in c1Data) {
          Map<String, String> paramMap = {};
          // Convertir los campos de item a minúsculas
          item.forEach((key, value) {
            paramMap[key.toLowerCase()] = value.toString();
          });
          unionParametros.add(paramMap);
        }
      } else {
        mostrarError(
            'Error al obtener los datos. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      mostrarError('Error al cargar datos');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venta Consolidada'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  if (unionParametros.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: CustomDataTable(
                            columns: const [
                              DataColumn(label: Text('Ubicacion')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Venta')),
                              DataColumn(label: Text('Devolucion')),
                              DataColumn(
                                  label: Text('Ventas Menos devolucion')),
                              DataColumn(label: Text('Venta Neta')),
                              DataColumn(label: Text('Impuestos')),
                              DataColumn(label: Text('Tickets')),
                              DataColumn(label: Text('Piezas')),
                            ],
                            rows: unionParametros.map((param) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(param['ubicacion'] ?? '')),
                                  DataCell(Text(param['nombre'] ?? '')),
                                  DataCell(Text(param['venta'] ?? '')),
                                  DataCell(Text(param['devoluciones'] ?? '')),
                                  DataCell(Text(param['ventasmenosdev'] ?? '')),
                                  DataCell(Text(param['venta_neta'] ?? '')),
                                  DataCell(Text(param['impuestos'] ?? '')),
                                  DataCell(Text(param['tickets'] ?? '')),
                                  DataCell(Text(param['piezas'] ?? '')),
                                ],
                              );
                            }).toList(),
                            footerRows: const [],
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
