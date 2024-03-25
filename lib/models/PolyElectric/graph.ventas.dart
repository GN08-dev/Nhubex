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
  String selectedMes = '1'; // Mes seleccionado inicialmente
  String selectedMesAnterior = '1'; // Mes anterior seleccionado

  final Map<String, String> meses = {
    'Enero': '1',
    'Febrero': '2',
    'Marzo': '3',
    'Abril': '4',
    'Mayo': '5',
    'Junio': '6',
    'Julio': '7',
    'Agosto': '8',
    'Septiembre': '9',
    'Octubre': '10',
    'Noviembre': '11',
    'Diciembre': '12',
  };

  @override
  void initState() {
    super.initState();
    loadSelectedMes(); // Cargar el mes seleccionado al iniciar la aplicación
  }

  // Método para cargar el mes seleccionado desde SharedPreferences
  Future<void> loadSelectedMes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMes = prefs.getString('selectedMes');
    if (savedMes != null) {
      setState(() {
        selectedMes = savedMes;
      });
      getData(selectedMes); // Obtener datos para el mes seleccionado
    }
  }

  // Método para obtener datos del servidor para un mes dado
  Future<void> getData(String selectedMes) async {
    setState(() {
      loading = true; // Iniciar indicador de carga
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Limpiar el caché del mes anterior si existe
      await prefs.remove('cachedData_$selectedMesAnterior');

      final response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/PE?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%22Mes%22:%22$selectedMes%22%7D%7D&format=JSON&isFront=true',
      );
      if (response.statusCode == 200) {
        // Actualizar los datos temporales con los nuevos datos
        setState(() {
          datosTemporales = json.decode(response.data)["RESPUESTA"]["registro"];
          loading = false; // Detener indicador de carga
        });

        // Guardar el nuevo mes seleccionado
        setState(() {
          selectedMesAnterior = selectedMes;
        });

        // Guardar el mes seleccionado en SharedPreferences
        prefs.setString('selectedMes', selectedMes);
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
        title: Row(
          children: [
            const Text('Ventas - '),
            DropdownButton<String>(
              value: selectedMes,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMes = newValue;
                  });
                  getData(
                      selectedMes); // Obtener datos para el mes seleccionado
                }
              },
              items: meses.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList(),
            )
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.black,
            height: 0.5,
          ),
        ),
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
