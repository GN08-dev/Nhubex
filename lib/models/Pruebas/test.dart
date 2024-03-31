import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Prueba extends StatefulWidget {
  final String companyName;

  const Prueba({Key? key, required this.companyName}) : super(key: key);

  @override
  _PruebaState createState() => _PruebaState();
}

class _PruebaState extends State<Prueba> {
  bool loading = false;
  double totalValorNetoSemana = 0.0;
  late List<dynamic> datosTemporales;
  late List<String> sucursalesDisponibles = [];
  String selectedSucursal =
      'Todas las Sucursales'; // Selecciona "Todas las Sucursales" por defecto

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    try {
      Response response;
      response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
      );

      if (response.statusCode == 200) {
        datosTemporales = json.decode(response.data)["RESPUESTA"]["registro"];
        sucursalesDisponibles = obtenerSucursales(datosTemporales);
        calculateData(); // Calcular los datos al cargar
        setState(() {
          loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error: $e');
    }
  }

  List<String> obtenerSucursales(List<dynamic> datos) {
    Set<String> sucursales = {};
    datos.forEach((registro) {
      String nombre = registro["Nombre"];
      sucursales.add(nombre);
    });
    return ['Todas las Sucursales', ...sucursales.toList()];
  }

  void calculateData() {
    // Obtener la fecha actual
    DateTime now = DateTime.now();

    // Obtener el primer día de la semana (lunes)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Filtrar los datos de la última semana
    List<dynamic> datosSemana = datosTemporales.where((registro) {
      // Convertir la fecha del registro a DateTime
      DateTime fecha = DateTime.parse(registro["Fecha"]);
      // Verificar si la fecha está dentro de la última semana
      return fecha.isAfter(startOfWeek.subtract(Duration(days: 1)));
    }).toList();

    // Inicializar el total del valor neto de la semana
    totalValorNetoSemana = 0.0;

    // Procesar los datos de la semana
    datosSemana.forEach((registro) {
      // Verificar si la sucursal seleccionada es "Todas las Sucursales"
      if (selectedSucursal == 'Todas las Sucursales') {
        dynamic valorNetoData = registro['ValorNeto'];
        if (valorNetoData != null) {
          // Verificar si el valor neto no es nulo antes de sumarlo
          double valorNeto = double.tryParse(valorNetoData.toString()) ?? 0.0;
          totalValorNetoSemana += valorNeto;
        }
      } else {
        // Verificar si el registro corresponde a la sucursal seleccionada
        if (registro['Nombre'] == selectedSucursal) {
          dynamic valorNetoData = registro['ValorNeto'];
          if (valorNetoData != null) {
            // Verificar si el valor neto no es nulo antes de sumarlo
            double valorNeto = double.tryParse(valorNetoData.toString()) ?? 0.0;
            totalValorNetoSemana += valorNeto;
          }
        }
      }
    });

    // Imprimir el total del valor neto de la semana
    print(
        'Total Valor Neto de la Semana: \$${totalValorNetoSemana.toString()}');

    // Llamar a la función para imprimir los totales de ventas por sucursal
    ImpresionSucursalTotalVenta();
  }

  void ImpresionSucursalTotalVenta() {
    // Obtener la fecha actual
    DateTime now = DateTime.now();

    // Obtener el primer día de la semana (lunes)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Filtrar los datos de la última semana
    List<dynamic> datosSemana = datosTemporales.where((registro) {
      // Convertir la fecha del registro a DateTime
      DateTime fecha = DateTime.parse(registro["Fecha"]);
      // Verificar si la fecha está dentro de la última semana
      return fecha.isAfter(startOfWeek.subtract(Duration(days: 1)));
    }).toList();

    // Mapa para almacenar el total de ventas por sucursal
    Map<String, double> ventasPorSucursal = {};

    // Calcular el total de ventas por cada sucursal
    datosSemana.forEach((registro) {
      String sucursal = registro['Nombre'];
      dynamic valorNetoData = registro['ValorNeto'];
      if (valorNetoData != null) {
        // Verificar si el valor neto no es nulo antes de sumarlo
        double valorNeto = double.tryParse(valorNetoData.toString()) ?? 0.0;
        // Sumar el valor neto al total de ventas de la sucursal correspondiente
        ventasPorSucursal.update(sucursal, (value) => value + valorNeto,
            ifAbsent: () => valorNeto);
      }
    });

    // Imprimir el total de ventas por sucursal
    ventasPorSucursal.forEach((sucursal, totalVenta) {
      print(
          'Sucursal $sucursal vendió: \$${totalVenta.toStringAsFixed(2)} en la semana');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            DropdownButton<String>(
              value: selectedSucursal,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSucursal = newValue!;
                  calculateData();
                });
              },
              items: sucursalesDisponibles
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.zero,
                color: Colors.grey.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Total Valor Neto de la Semana',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalValorNetoSemana.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Prueba(companyName: 'POLY ELECTRIC'),
    ),
  );
}
