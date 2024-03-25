import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Ventas extends StatefulWidget {
  const Ventas({Key? key});

  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  List<dynamic> datosTemporales =
      []; // Lista para almacenar los datos temporales
  bool loading = false; // Indicador de carga

  @override
  void initState() {
    super.initState();
    getData(); // Obtener datos al iniciar la aplicación
  }

  // Método para obtener datos del servidor
  Future<void> getData() async {
    setState(() {
      loading = true; // Iniciar indicador de carga
    });

    try {
      final response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
      );
      if (response.statusCode == 200) {
        // Actualizar los datos temporales con los nuevos datos
        setState(() {
          datosTemporales = json.decode(response.data)["RESPUESTA"]["registro"];
          loading = false; // Detener indicador de carga
        });
      } else {
        setState(() {
          loading = false; // Detener indicador de carga
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false; // Detener indicador de carga
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        if (datosTemporales.isNotEmpty)
                          Container(
                            height: 300,
                            child: SfCartesianChart(
                              // Configurar el gráfico de barras
                              primaryXAxis:
                                  CategoryAxis(), // Eje X para las categorías
                              series: <ChartSeries>[
                                // Serie de barras
                                BarSeries<Map<String, dynamic>, String>(
                                  // Los datos para la serie son los datos temporales
                                  dataSource: datosTemporales
                                      .map((e) => e as Map<String, dynamic>)
                                      .toList(),
                                  // Asignar el campo 'Nombre' al eje X (categoría)
                                  xValueMapper: (datum, _) =>
                                      datum['Nombre'] as String,
                                  // Asignar el campo 'ValorNeto' al eje Y (valor)
                                  yValueMapper: (datum, _) => double.parse(
                                      datum['ValorNeto'].toString()),
                                ),
                              ],
                            ),
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
