import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Graficas/graphbar.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/redireccionamiento.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class VentaConsilidada extends StatefulWidget {
  const VentaConsilidada({Key? key});

  @override
  State<VentaConsilidada> createState() => _VentaConsilidadaState();
}

class _VentaConsilidadaState extends State<VentaConsilidada> {
  String empresa = '';
  String nombre = '';
  String rolUsuario = '';
  String empresaSiglas = '';
  int anoSeleccionado = DateTime.now().year;
  int mesSeleccionado = DateTime.now().month;
  int diaSeleccionado = DateTime.now().day;
  String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Map<String, double> ventaNetaPorSucursal = {};

  bool loading = false;
  List<Map<String, String>> unionParametros = [];
  Map<String, String> sucursalesMap = {};
  String selectedSucursal =
      'Todas las sucursales'; // Inicializamos con "Todas las sucursales"
  List<String> sucursalesOptions = [
    'Todas las sucursales'
  ]; // Agregamos la opción "Todas las sucursales" al inicio

  //paginas
  int itemsPorPagina = 5;
  int paginaActual = 1;
  @override
  void initState() {
    super.initState();
    obtenerNombreEmpresa();
    obtenerNombreUsuario().then((_) {
      if (nombre.isNotEmpty) {
        obtenerSiglasEmpresa().then((_) {
          // Llamamos a obtenerDatos() después de obtener las siglas de la empresa
          obtenerDatos();
        });
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

  Future<void> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/$empresaSiglas?stored_name=rep_venta_consolidada&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombre%22,%22fini%22:%22$fecha%22,%22ffin%22:%22$fecha%22%7D%7D&format=JSON&isFront=true';
    try {
      final response = await Dio().get(url);
      print('URL: $url');

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
        // Obtener nombres de sucursales y sus ubicaciones
        for (var dato in unionParametros) {
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
        });
      } else {
        print('URL: $url');

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

  List<BarChartGroupData> convertirDatosAVentasBarChart(
      List<dynamic> datos, String sucursalSeleccionada) {
    Map<String, double> ventasPorIDUbicacion = {};

    // Filtra los datos por la sucursal seleccionada, si no es "Todas las sucursales"
    if (sucursalSeleccionada != 'Todas las sucursales') {
      final datosFiltrados = datos
          .where((dato) => dato['nombre'] == sucursalSeleccionada)
          .toList();

      for (var registro in datosFiltrados) {
        String idUbicacion = registro['ubicacion'].toString();
        double valor = double.tryParse(registro['venta_neta'] ?? '0.0') ?? 0.0;
        ventasPorIDUbicacion[idUbicacion] =
            (ventasPorIDUbicacion[idUbicacion] ?? 0) + valor;
      }
    } else {
      // Si se selecciona "Todas las sucursales", mostramos todas las ubicaciones
      for (var registro in datos) {
        String idUbicacion = registro['ubicacion'].toString();
        double valor = double.tryParse(registro['venta_neta'] ?? '0.0') ?? 0.0;
        ventasPorIDUbicacion[idUbicacion] =
            (ventasPorIDUbicacion[idUbicacion] ?? 0) + valor;
      }
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

  ///get de datos de pagina
  List<Map<String, dynamic>> getDatosPagina(int pagina) {
    final startIndex = (pagina - 1) * itemsPorPagina;
    final endIndex = startIndex + itemsPorPagina;
    return unionParametros.sublist(startIndex,
        endIndex < unionParametros.length ? endIndex : unionParametros.length);
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
    return total.toStringAsFixed(2); // Ajusta la precisión según sea necesario
  }

  // Función para formatear números con coma después de los miles y dos dígitos después del punto decimal
  String formatNumber(String value) {
    double numericValue = double.tryParse(value) ?? 0.0;
    NumberFormat formatter = NumberFormat('#,##0.00');
    return formatter.format(numericValue);
  }

  int daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM', 'es_MX').format(DateTime.now());

    double ventaNetaTotal = double.tryParse(calcularTotal('venta_neta')) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Venta Consolidada',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'por rango de fechas',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
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
                                      obtenerDatos(); // Llama a obtenerDatos() cuando se selecciona una nueva fecha
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
                    '\$${formatNumber(ventaNetaTotal.toString())}', // Muestra la venta neta total
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: SalesBarChart(
                      convertirDatosAVentasBarChart(unionParametros,
                          selectedSucursal), // Pasamos la sucursal seleccionada a la función
                      unionParametros
                          .map((dato) => dato['ubicacion'].toString())
                          .toList(),
                    ),
                  ),
                  SizedBox(
                    child: Container(
                      height: 300,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              children: [
                                if (unionParametros.isNotEmpty)
                                  CustomDataTable(
                                    columns: const [
                                      DataColumn(label: Text('Ubicacion')),
                                      DataColumn(label: Text('Nombre')),
                                      DataColumn(label: Text('Venta Neta')),
                                      DataColumn(label: Text('Devolucion')),
                                      DataColumn(
                                          label:
                                              Text('Ventas Menos devolucion')),
                                      DataColumn(
                                          label: Text('Venta sin impuesto')),
                                      DataColumn(label: Text('Impuestos')),
                                      DataColumn(label: Text('Tickets')),
                                      DataColumn(
                                          label: Text('Promedio Tickets')),
                                      DataColumn(label: Text('Piezas')),
                                    ],
                                    rows: unionParametros
                                        .where((param) =>
                                            param['nombre'] ==
                                                selectedSucursal ||
                                            selectedSucursal ==
                                                'Todas las sucursales')
                                        .map((param) {
                                      double tickets = double.tryParse(
                                              param['tickets'] ?? '0.0') ??
                                          0.0;
                                      double ventas = double.tryParse(
                                              param['venta_neta'] ?? '0.0') ??
                                          0.0;
                                      double promedioTickets = tickets != 0.0
                                          ? ventas / tickets
                                          : 0.0;
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(param['ubicacion'] ?? ''),
                                          ),
                                          DataCell(
                                            Text(param['nombre'] ?? ''),
                                          ),
                                          DataCell(
                                            Text(
                                              formatNumber(
                                                  param['venta_neta'] ?? ''),
                                            ),
                                          ),
                                          DataCell(
                                            Text(formatNumber(
                                                param['devoluciones'] ?? '')),
                                          ),
                                          DataCell(
                                            Text(formatNumber(
                                                param['ventasmenosdev'] ?? '')),
                                          ),
                                          DataCell(
                                            Text(formatNumber(
                                                param['venta'] ?? '')),
                                          ),
                                          DataCell(
                                            Text(formatNumber(
                                                param['impuestos'] ?? '')),
                                          ),
                                          DataCell(
                                            Text(formatNumber(
                                                param['tickets'] ?? '')),
                                          ),
                                          DataCell(
                                            Text(formatNumber(
                                                promedioTickets.toString())),
                                          ),
                                          DataCell(
                                            Text(formatNumber(
                                                param['piezas'] ?? '')),
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
                                            formatNumber(calcularTotal(
                                                'ventasmenosdev')),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            formatNumber(
                                                calcularTotal('venta')),
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
                                            formatNumber(
                                                calcularTotal('tickets')),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            formatNumber((ventaNetaTotal /
                                                    (double.tryParse(
                                                            calcularTotal(
                                                                'tickets')) ??
                                                        1))
                                                .toStringAsFixed(2)),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            formatNumber(
                                                calcularTotal('piezas')),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ),
                              ],
                            ),
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
