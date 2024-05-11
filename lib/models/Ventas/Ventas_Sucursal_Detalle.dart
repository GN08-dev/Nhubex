import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/redireccionamiento.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Graficas/graphbar.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';

class VentasSucursalDetalle extends StatefulWidget {
  const VentasSucursalDetalle({super.key});

  @override
  State<VentasSucursalDetalle> createState() => _VentasSucursalDetalleState();
}

class _VentasSucursalDetalleState extends State<VentasSucursalDetalle> {
  String empresa = '';
  String nombre = '';
  String rolUsuario = '';
  String empresaSiglas = '';

  int anoSeleccionado = DateTime.now().year;
  int mesSeleccionado = DateTime.now().month;
  int diaSeleccionado = DateTime.now().day;
  String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool loading = false;
  List<Map<String, dynamic>> datosC1 = [];
  int itemsPorPagina = 5;
  int paginaActual = 1;
  //filtros
  double sumaVentaNetaTotal = 0.0;
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

  @override
  void initState() {
    super.initState();
    obtenerNombreUsuario().then((_) {
      if (nombre.isNotEmpty) {
        obtenerNombreEmpresa();
        obtenerSiglasEmpresa().then((_) {
          obtenerDatos().then((data) {
            setState(() {
              datosC1 = data;
              calcularEstadisticas();
              calcularVentaNetaPorSucursal();
              actualizarListaSucursales();
            });
          });
        }).catchError((error) {
          mostrarError('Error al obtener las siglas de la empresa: $error');
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

    // Limpia los datos antes de cargar nuevos datos
    datosC1.clear();

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/$empresaSiglas?stored_name=rep_venta_Sucursal_Detalle&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombre%22,%22fini%22:%22$fecha%22,%22ffin%22:%22$fecha%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        // Procesa y almacena los datos recibidos en `datosC1`
        for (var item in c1Data) {
          Map<String, dynamic> itemLowerCase = {};
          item.forEach((key, value) {
            itemLowerCase[key.toLowerCase()] = value;
          });
          datosC1.add(itemLowerCase);
        }

        // Calcular los totales
        double totalVenta = 0;
        double totalDevoluciones = 0;
        double totalVentasMenosDev = 0;
        double totalVentaNeta = 0;
        double totalImpuestos = 0;
        double totalTickets = 0;
        double totalPiezas = 0;

        for (var registro in datosC1) {
          totalVenta += double.tryParse(registro['venta'] ?? '0.0') ?? 0.0;
          totalDevoluciones +=
              double.tryParse(registro['devoluciones'] ?? '0.0') ?? 0.0;
          totalVentaNeta +=
              double.tryParse(registro['venta_neta'] ?? '0.0') ?? 0.0;
          totalVentasMenosDev +=
              double.tryParse(registro['ventasmenosdev'] ?? '0.0') ?? 0.0;
          totalImpuestos +=
              double.tryParse(registro['impuestos'] ?? '0.0') ?? 0.0;
          totalTickets += double.tryParse(registro['tickets'] ?? '0.0') ?? 0.0;
          totalPiezas += double.tryParse(registro['piezas'] ?? '0.0') ?? 0.0;
        }

        // Actualizar el estado de los totales
        setState(() {
          totalVentaTotal = totalVenta;
          totalDevolucionesTotal = totalDevoluciones;
          totalVentasMenosDevTotal = totalVentasMenosDev;
          totalVentaNetaTotal = totalVentaNeta;
          totalImpuestosTotal = totalImpuestos;
          totalTicketsTotal = totalTickets;
          totalPiezasTotal = totalPiezas;
          // Calcular el promedio de venta neta por ticket
          totalPromedioTicket = totalVentaNetaTotal / totalTicketsTotal;
        });

        return datosC1;
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

  void calcularEstadisticas() {
    sumaVentaNetaTotal = datosC1.fold<double>(0, (previousValue, element) {
      return previousValue +
          (double.tryParse(element['Venta_Neta'] ?? '0.0') ?? 0.0);
    });
  }

  void calcularVentaNetaPorSucursal() {
    for (var item in datosC1) {
      final nombreSucursal = item['nombre'] as String;
      final ventaNeta = double.tryParse(item['Venta_Neta'] ?? '0.0') ?? 0.0;
      ventaNetaPorSucursal[nombreSucursal] =
          (ventaNetaPorSucursal[nombreSucursal] ?? 0) + ventaNeta;
    }
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
        // ignore: unused_local_variable
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
  ////CALCULAR FORMA DE PAGO

  // Totales
  double totalVentaTotal = 0;
  double totalDevolucionesTotal = 0;
  double totalVentaNetaTotal = 0;
  double totalVentasMenosDevTotal = 0;
  double totalImpuestosTotal = 0;
  double totalTicketsTotal = 0;
  double totalPromedioTicket = 0;
  double totalPiezasTotal = 0;

  double calcularSumaVentaNetaTotal() {
    final datosFiltrados =
        filtrarDatosPorSucursalTabla(datosC1, selectedSucursal);
    return datosFiltrados.fold<double>(0, (previousValue, element) {
      return previousValue +
          (double.tryParse(element['venta_neta'] ?? '0.0') ?? 0.0);
    });
  }

  int daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  String formatNumber(String value) {
    double numericValue = double.tryParse(value) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericValue);
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

  @override
  Widget build(BuildContext context) {
    double ventaNetaTotal = double.tryParse(calcularTotal('venta_neta')) ?? 0.0;

    String currentMonth = DateFormat('MMMM', 'es_MX').format(DateTime.now());

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
                    ExpansionTile(
                      title: const Text(
                        'Seleccionar Fecha',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      children: [
                        StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Alinear hacia la izquierda
                              children: [
                                //
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          4), // Espacio vertical entre los elementos
                                  child: ExpansionTile(
                                    initiallyExpanded:
                                        false, // Inicialmente contraído
                                    title: Text(
                                        'Año: ${anoSeleccionado.toString()}',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    children: List.generate(
                                      10, // Cambia este valor según tu rango de años necesarios
                                      (index) {
                                        int ano = DateTime.now().year - index;
                                        return ListTile(
                                          title: Text(ano.toString(),
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          onTap: () {
                                            setState(() {
                                              anoSeleccionado = ano;
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          4), // Espacio vertical entre los elementos
                                  child: ExpansionTile(
                                    initiallyExpanded:
                                        false, // Inicialmente contraído
                                    title: Text(
                                        'Mes: ${(mesSeleccionado).toString()}',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    children: List.generate(
                                      12,
                                      (index) {
                                        return ListTile(
                                          title: Text((index + 1).toString(),
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          onTap: () {
                                            setState(() {
                                              mesSeleccionado = index + 1;
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          4), // Espacio vertical entre los elementos
                                  child: ExpansionTile(
                                    initiallyExpanded:
                                        false, // Inicialmente contraído
                                    title: Text(
                                        'Día: ${(diaSeleccionado).toString()}',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    children: List.generate(
                                      daysInMonth(
                                          mesSeleccionado, anoSeleccionado),
                                      (index) {
                                        return ListTile(
                                          title: Text((index + 1).toString(),
                                              style: const TextStyle(
                                                  color: Colors.white)),
                                          onTap: () {
                                            setState(() {
                                              diaSeleccionado = index + 1;
                                            });
                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical:
                                          8), // Espacio vertical entre los elementos
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                        context,
                                        DateTime(
                                          anoSeleccionado,
                                          mesSeleccionado,
                                          diaSeleccionado,
                                        ),
                                      );
                                      setState(() {
                                        fecha = DateFormat('yyyy-MM-dd').format(
                                            DateTime(
                                                anoSeleccionado,
                                                mesSeleccionado,
                                                diaSeleccionado));
                                      });
                                      obtenerDatos().then((_) {
                                        actualizarListaSucursales(); // Actualiza las sucursales después de obtener los datos
                                      });
                                    },
                                    child: const Text(
                                      'Aceptar',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

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
            const Text(
              'Ventas por ',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Sucursal',
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
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
                    ).format(calcularSumaVentaNetaTotal())}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Gráfica de ventas por forma de pago
                  SizedBox(
                    height: 300,
                    child: SalesBarChart(
                      convertirDatosAVentasBarChart(
                          filtrarDatosPorSucursalTabla(
                              datosC1, selectedSucursal)),
                      filtrarDatosPorSucursalTabla(datosC1, selectedSucursal)
                          .map((dato) => dato['ubicacion'].toString())
                          .toList(),
                    ),
                  ),

                  Container(
                    height: 300,
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
                                DataColumn(label: Text('Fecha')),
                                DataColumn(label: Text('Venta Neta')),
                                DataColumn(label: Text('Devoluciones')),
                                DataColumn(label: Text('Ventas Menos Dev')),
                                DataColumn(label: Text('Venta Sin Impuesto')),
                                DataColumn(label: Text('Impuestos')),
                                DataColumn(label: Text('Tickets')),
                                DataColumn(
                                  label: Text(
                                    'Promedio Tickets',
                                  ), // Nueva columna para la venta neta por ticket
                                ),
                                DataColumn(label: Text('Piezas')),
                              ],
                              rows: filtrarDatosPorSucursalTabla(
                                      datosC1, selectedSucursal)
                                  .map((datos) {
                                final double ventaNeta = double.tryParse(
                                        datos['venta_neta'] ?? '0.0') ??
                                    0.0;
                                final int tickets =
                                    int.tryParse(datos['tickets'] ?? '0') ?? 0;
                                final double ventaNetaPorTicket =
                                    tickets != 0 ? ventaNeta / tickets : 0.0;

                                return DataRow(
                                  cells: [
                                    DataCell(Text(datos['ubicacion'] ?? '')),
                                    DataCell(Text(datos['nombre'] ?? '')),
                                    DataCell(Text(datos['fecha'] ?? '')),
                                    DataCell(Text(NumberFormat('#,###.00')
                                        .format(ventaNeta))),
                                    DataCell(Text(NumberFormat('#,###.00')
                                        .format(double.tryParse(
                                                datos['devoluciones'] ??
                                                    '0.0') ??
                                            0.0))),
                                    DataCell(Text(NumberFormat('#,###.00')
                                        .format(double.tryParse(
                                                datos['ventasmenosdev'] ??
                                                    '0.0') ??
                                            0.0))),
                                    DataCell(Text(NumberFormat('#,###.00')
                                        .format(double.tryParse(
                                                datos['venta'] ?? '0.0') ??
                                            0.0))),
                                    DataCell(Text(NumberFormat('#,###.00')
                                        .format(double.tryParse(
                                                datos['impuestos'] ?? '0.0') ??
                                            0.0))),
                                    DataCell(Text(NumberFormat('#,###.00')
                                        .format(tickets))),
                                    DataCell(Text(
                                        ventaNetaPorTicket.toStringAsFixed(2))),
                                    DataCell(Text(NumberFormat('#,###.00')
                                        .format(double.tryParse(
                                                datos['piezas'] ?? '0.0') ??
                                            0.0))),
                                  ],
                                );
                              }).toList(),
                              footerRows: [
                                DataRow(cells: [
                                  const DataCell(Text('')),
                                  const DataCell(Text('')),
                                  const DataCell(
                                    Text('Total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  DataCell(
                                    Text(
                                      formatNumber(calcularTotal('venta_neta')),
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
                                      formatNumber(calcularTotal('impuestos')),
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
                                  DataCell(
                                    Text(
                                      formatNumber((ventaNetaTotal /
                                              (double.tryParse(calcularTotal(
                                                      'tickets')) ??
                                                  1))
                                          .toStringAsFixed(2)),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
