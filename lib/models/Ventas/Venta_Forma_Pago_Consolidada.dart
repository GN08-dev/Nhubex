import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/Table/DataTable.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/redireccionamiento.dart';
import 'package:flutter_proyect/components/menu_desplegable/info_card.dart';
import 'package:flutter_proyect/models/Ventas/Graficas/GraficaDePastelDeForma_pagoDetalle.dart';
import 'package:intl/intl.dart';

class VentaFormaPagoConsolidada extends StatefulWidget {
  const VentaFormaPagoConsolidada({Key? key});

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
  int anoSeleccionado = DateTime.now().year;
  int mesSeleccionado = DateTime.now().month;
  int diaSeleccionado = DateTime.now().day;
  String fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int currentPage = 0;
  int rowsPerPage = 4;
  @override
  void initState() {
    super.initState();
    obtenerNombreUsuario();
    obtenerRolUsuario();
    obtenerNombreEmpresa();
    obtenerSiglasEmpresa().then((_) {
      // Llamamos a obtenerDatos() después de obtener las siglas de la empresa
      obtenerDatos();
    }).catchError((error) {
      mostrarError('Error al obtener las siglas de la empresa: $error');
    });
  }

  Future<void> obtenerDatos() async {
    setState(() {
      loading = true;
    });

    // Limpia los datos antes de cargar nuevos datos
    datosC1.clear();
    formasDePago.clear();
    ventasPorSucursalYFormaPago.clear();
    nombres.clear();

    final url =
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/$empresaSiglas?stored_name=rep_venta_consolidada_forma_pago_optimizado&attributes=%7B%22DATOS%22:%7B%22ubicacion%22:%22%22,%22uactivo%22:%22$nombreUsuario%22,%22fini%22:%22$fecha%22,%22ffin%22:%22$fecha%22%7D%7D&format=JSON&isFront=true';

    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.data);
        final List<dynamic> c1Data = data['RESPUESTA']['C1'];

        // Procesa y almacena los datos recibidos en `datosC1`
        datosC1.addAll(List<Map<String, dynamic>>.from(c1Data));

        setState(() {
          obtenerTotalVentasPorSucursalYFormaPago();
        });
      } else {
        throw 'Error al obtener los datos del JSON. Código de estado: ${response.statusCode}';
      }
    } catch (e) {
      print('Error: $e');
      mostrarError('Error al cargar los datos.');
    } finally {
      setState(() => loading = false);
      print('URL cargada: $url');
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

  int daysInMonth(int month, int year) {
    return DateTime(year, month + 1, 0).day;
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
      body: Padding(
        padding: EdgeInsets.all(3),
        child: loading
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
                        ExpansionTile(
                          title: Padding(
                            padding: const EdgeInsets.only(
                                left:
                                    50), // Ajusta el espacio a la izquierda según lo necesites
                            child: Text(
                              currentMonth.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          children: [
                            StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                int currentYear = DateTime.now().year;
                                int currentMonth = DateTime.now().month;
                                int currentDay = DateTime.now().day;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('Año: ',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              DropdownButton<int>(
                                                value: anoSeleccionado,
                                                items:
                                                    List.generate(6, (index) {
                                                  int ano = currentYear - index;
                                                  return DropdownMenuItem<int>(
                                                    value: ano,
                                                    child: Text(ano.toString(),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black)),
                                                  );
                                                }),
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    anoSeleccionado = newValue!;
                                                    // Ajustar el mes y día seleccionado si es necesario
                                                    if (anoSeleccionado ==
                                                            currentYear &&
                                                        mesSeleccionado >
                                                            currentMonth) {
                                                      mesSeleccionado =
                                                          currentMonth;
                                                    }
                                                    if (anoSeleccionado ==
                                                            currentYear &&
                                                        mesSeleccionado ==
                                                            currentMonth &&
                                                        diaSeleccionado >
                                                            currentDay) {
                                                      diaSeleccionado =
                                                          currentDay;
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ), // Dropdown para el mes
                                          Row(
                                            children: [
                                              const Text('Mes: ',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              DropdownButton<int>(
                                                value: mesSeleccionado,
                                                items: List.generate(
                                                  anoSeleccionado == currentYear
                                                      ? currentMonth
                                                      : 12,
                                                  (index) {
                                                    int month;
                                                    if (anoSeleccionado ==
                                                        currentYear) {
                                                      month =
                                                          currentMonth - index;
                                                    } else {
                                                      month = 12 - index;
                                                    }
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: month,
                                                      child: Text(
                                                          month.toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                    );
                                                  },
                                                ),
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    mesSeleccionado = newValue!;
                                                    // Ajustar el día seleccionado si es necesario
                                                    if (anoSeleccionado ==
                                                            currentYear &&
                                                        mesSeleccionado ==
                                                            currentMonth &&
                                                        diaSeleccionado >
                                                            currentDay) {
                                                      diaSeleccionado =
                                                          currentDay;
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          // Dropdown para el día
                                          Row(
                                            children: [
                                              const Text('Día: ',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              DropdownButton<int>(
                                                value: diaSeleccionado,
                                                items: List.generate(
                                                  anoSeleccionado ==
                                                              currentYear &&
                                                          mesSeleccionado ==
                                                              currentMonth
                                                      ? currentDay
                                                      : daysInMonth(
                                                          mesSeleccionado,
                                                          anoSeleccionado),
                                                  (index) {
                                                    int day;
                                                    if (anoSeleccionado ==
                                                            currentYear &&
                                                        mesSeleccionado ==
                                                            currentMonth) {
                                                      day = currentDay - index;
                                                    } else {
                                                      day = daysInMonth(
                                                              mesSeleccionado,
                                                              anoSeleccionado) -
                                                          index;
                                                    }
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: day,
                                                      child: Text(
                                                          day.toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                    );
                                                  },
                                                ),
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    diaSeleccionado = newValue!;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() {
                                              fecha = DateFormat('yyyy-MM-dd')
                                                  .format(DateTime(
                                                anoSeleccionado,
                                                mesSeleccionado,
                                                diaSeleccionado,
                                              ));
                                              obtenerDatos(); // Llama a obtenerDatos() cuando se selecciona una nueva fecha
                                            });
                                          },
                                          child: const Text(
                                            'Aceptar',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
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
                                10.0), // Ajusta según necesites
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
                                  const DataColumn(
                                      label: Text(
                                          'Total')), // Nueva columna "Total"
                                ],
                                rows: ventasPorSucursalYFormaPago.entries
                                    .skip(currentPage * rowsPerPage)
                                    .take(rowsPerPage)
                                    .map((entry) {
                                  // Obtener el nombre correspondiente a la ubicación
                                  String nombre = nombres.firstWhere(
                                      (nombre) => datosC1.any((item) =>
                                          item['ubicacion'] == entry.key &&
                                          item['nombre'] == nombre),
                                      orElse: () => '');

                                  // Calcular el total para todas las formas de pago
                                  double totalPorUbicacion =
                                      formasDePago.fold(0.0, (sum, formaPago) {
                                    return sum +
                                        (entry.value[formaPago] ?? 0.0);
                                  });

                                  return DataRow(cells: [
                                    DataCell(Text(entry.key)), // Ubicación
                                    DataCell(Text(nombre)), // Nombre
                                    for (var formaPago in formasDePago)
                                      DataCell(Text(
                                        '${entry.value[formaPago] != null ? NumberFormat("#,##0.00").format(entry.value[formaPago]!) : "0.00"}',
                                      )),
                                    DataCell(Text(
                                      '${NumberFormat("#,##0.00").format(totalPorUbicacion)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )), // Columna "Total"
                                  ]);
                                }).toList(),
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
                                          '${totalVentaGeneral()[formaPago] != null ? NumberFormat("#,##0.00").format(totalVentaGeneral()[formaPago]!) : "0.00"}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    DataCell(
                                      Text(
                                        '${NumberFormat("#,##0.00").format(calcularVentaTotalNetaGeneral())}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ), // Total general
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Centrar los elementos horizontalmente
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
                                      ventasPorSucursalYFormaPago.length
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
    );
  }
}
