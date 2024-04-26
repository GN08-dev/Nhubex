import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Prueba2 extends StatefulWidget {
  const Prueba2({Key? key}) : super(key: key);

  @override
  State<Prueba2> createState() => _Prueba2State();
}

class _Prueba2State extends State<Prueba2> {
  bool loading = false;
  List<Map<String, dynamic>> datosC1 = [];
  List<String> selectedColumns = [];
  int currentPage = 0;
  static const int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    obtenerDatos();
    cargarConfiguracion();
  }

  Future<void> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    const url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/ve?stored_name=rep_venta_detalle_forma_pago&attributes=%7B%22DATOS%22:%7B%22uactivo%22:%22shernandez%22,%22fini%22:%222024-04-18%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];
        setState(() {
          datosC1 = List<Map<String, dynamic>>.from(c1Data);
          loading = false;
        });
      } else {
        mostrarError(
            'Error al obtener los datos del JSON. Código de estado: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      mostrarError('Error al cargar los datos.');
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void cargarConfiguracion() async {
    String empresaId = 'pe';
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Empresa')
          .doc(empresaId)
          .get();
      if (docSnapshot.exists) {
        setState(() {
          selectedColumns = List<String>.from(
              docSnapshot.data()?['Ventas_Forma_Pago_Detalle_colum'] ?? []);
        });
      } else {
        setState(() {
          // Si no hay configuración en Firestore, selecciona todas las columnas si hay datos
          selectedColumns =
              datosC1.isNotEmpty ? List<String>.from(datosC1.first.keys) : [];
        });
      }
    } catch (e) {
      print('Error al cargar la configuración: $e');
    }
  }

  List<Map<String, dynamic>> get currentPageData {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return datosC1.sublist(
        startIndex, endIndex > datosC1.length ? datosC1.length : endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de datos'),
      ),
      endDrawer: Drawer(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : datosC1.isNotEmpty
                ? ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      const DrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                        ),
                        child: Text(
                          'Seleccionar Columnas a Mostrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      if (selectedColumns.isEmpty)
                        const ListTile(
                          title: Text('No hay columnas seleccionadas'),
                        ),
                      for (var columna in datosC1.first.keys)
                        CheckboxListTile(
                          title: Text(columna),
                          value: selectedColumns.contains(columna),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                if (value) {
                                  selectedColumns.add(columna);
                                } else {
                                  selectedColumns.remove(columna);
                                  // Verificar si quedan columnas seleccionadas, si no, seleccionar todas
                                  if (selectedColumns.isEmpty) {
                                    selectedColumns =
                                        List<String>.from(datosC1.first.keys);
                                  }
                                }
                              }
                            });
                          },
                        ),
                      ElevatedButton(
                        onPressed: guardarConfiguracion,
                        child: const Text('Guardar Configuración'),
                      ),
                    ],
                  )
                : Container(),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : selectedColumns.isNotEmpty
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          child: DataTable(
                            columns: _buildColumns(),
                            rows: _buildRows(),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: currentPage > 0
                                    ? () => setState(() => currentPage -= 1)
                                    : null,
                                child: const Text('Anterior'),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                '${currentPage + 1} / ${((datosC1.length - 1) / itemsPerPage).ceil()}',
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: currentPage <
                                        ((datosC1.length - 1) / itemsPerPage)
                                                .ceil() -
                                            1
                                    ? () => setState(() => currentPage += 1)
                                    : null,
                                child: const Text('Siguiente'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: const Text(
                      'Por el momento no cuentas con informacion en las columnas'),
                ),
    );
  }

  List<DataColumn> _buildColumns() {
    final List<DataColumn> columns = [];
    for (var columna in selectedColumns) {
      columns.add(DataColumn(label: Text(columna)));
    }
    return columns;
  }

  List<DataRow> _buildRows() {
    if (currentPageData.isEmpty) return [];

    return currentPageData.map<DataRow>((data) {
      return DataRow(cells: _buildCells(data));
    }).toList();
  }

  List<DataCell> _buildCells(Map<String, dynamic> data) {
    final List<DataCell> cells = [];
    for (var columna in selectedColumns) {
      cells.add(DataCell(Text('${data[columna]}')));
    }
    return cells;
  }

  Future<void> guardarConfiguracion() async {
    String empresaId = 'pe';
    await FirebaseFirestore.instance.collection('Empresa').doc(empresaId).set({
      'Ventas_Forma_Pago_Detalle_colum': selectedColumns,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada con éxito')),
    );
  }
}
