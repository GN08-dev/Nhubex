import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/redireccionamiento.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_proyect/design/kit_de_estilos/graficas/graphbar.dart';

class VentaTicketConsolidado extends StatefulWidget {
  const VentaTicketConsolidado({Key? key}) : super(key: key);

  @override
  State<VentaTicketConsolidado> createState() => _VentaTicketConsolidadoState();
}

class _VentaTicketConsolidadoState extends State<VentaTicketConsolidado> {
  String empresa = '';
  String nombre = '';
  String rolUsuario = '';
  String empresaSiglas = '';
  String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());

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
        obtenerSiglasEmpresa().then((_) {
          // Esperar a obtener las siglas antes de obtener los datos
          obtenerDatos().then((data) {
            setState(() {
              datosC1 = data;
            });
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
    String nombreEmpresa = await MenuHelper.obtenerNombreEmpresa();
    setState(() {
      empresa = nombreEmpresa;
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

  Future<List<Map<String, dynamic>>> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/$empresaSiglas?stored_name=rep_venta_ticket_consolidado&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombre%22,%22fini%22:%222024-04-18%22,%22ffin%22:%222024-04-19%22%7D%7D&format=JSON&isFront=true';

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
        // Actualizamos las opciones del DropdownButton
        setState(() {
          sucursalesOptions.addAll(sucursalesMap.keys.toList());
          // Verificamos si hay algún valor en la lista de opciones
          if (sucursalesOptions.isNotEmpty) {
            // Establecemos el primer valor de la lista como seleccionado por defecto
            selectedSucursal = sucursalesOptions.first;
          }
          datosC1 = datos; // Asignar los datos antes de actualizar los totales
        });

        return datos;
      } else {
        print('URL: $url');

        mostrarError(
            'Error al obtener los datos del JSON. Código de estado: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('URL: $url');
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

  List<Map<String, dynamic>> filtrarDatosPorSucursal(
      List<Map<String, dynamic>> datos, String sucursal) {
    if (sucursal == 'Todas las sucursales') {
      return datos;
    } else {
      return datos.where((dato) => dato['nombre'] == sucursal).toList();
    }
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

  String calcularTotal(String columna) {
    double total = 0.0;
    for (var param in datosC1) {
      if (param['nombre'] == selectedSucursal ||
          selectedSucursal == 'Todas las sucursales') {
        double valor = double.tryParse(param[columna] ?? '0.0') ?? 0.0;
        total += valor;
      }
    }
    return total.toStringAsFixed(2); // Ajusta la precisión según sea necesario
  }

  // Función para formatear números con coma después de los miles y dos dígitos después del punto decimal
  String formatNumber(String value) {
    double numericValue = double.tryParse(value) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericValue);
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Venta por ticket',
              style: TextStyle(fontSize: 18), // Ajusta el tamaño del subtítulo
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: loading
            ? const Center(child: CircularProgressIndicator())
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
                    formatNumber(calcularTotal('venta_neta')),
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 300,
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.only(left: 1),
                    child: SalesBarChart(
                      convertirDatosAVentasBarChart(
                          filtrarDatosPorSucursal(datosC1, selectedSucursal)),
                      obtenerUbicacionesUnicas(
                          filtrarDatosPorSucursal(datosC1, selectedSucursal)),
                    ),
                  ),
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: CustomDataTable(
                          columns: const [
                            DataColumn(label: Text('Ubicación')),
                            DataColumn(label: Text('Sucursal')),
                            DataColumn(label: Text('Vendedor')),
                            DataColumn(label: Text('Venta Neta')),
                            DataColumn(label: Text('Venta')),
                            DataColumn(label: Text('Impuestos')),
                            DataColumn(label: Text('Ticket')),
                          ],
                          rows: getDatosPagina(paginaActual)
                              .map(
                                (dato) => DataRow(
                                  cells: [
                                    DataCell(
                                        Text(dato['ubicacion'].toString())),
                                    DataCell(Text(dato['nombre'].toString())),
                                    DataCell(Text(dato['vendedor'].toString())),
                                    DataCell(Text(
                                      // ignore: unnecessary_string_interpolations
                                      '${NumberFormat("#,##0.00").format(double.parse(dato['venta_neta'].toString()))}', // Aplica el formato con coma para miles
                                    )),
                                    DataCell(Text(
                                      // ignore: unnecessary_string_interpolations
                                      '${NumberFormat("#,##0.00").format(double.parse(dato['venta'].toString()))}', // Aplica el formato con coma para miles
                                    )),
                                    DataCell(Text(
                                      // ignore: unnecessary_string_interpolations
                                      '${NumberFormat("#,##0.00").format(double.parse(dato['impuestos'].toString()))}', // Aplica el formato con coma para miles
                                    )),
                                    DataCell(Text(dato['ticket'].toString())),
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
                                  formatNumber(calcularTotal('venta_neta')),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold))),
                              DataCell(
                                Text(
                                  formatNumber(calcularTotal('venta')),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(
                                  formatNumber(calcularTotal('impuestos')),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(''),
                              ),
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
      ),
    );
  }
}
