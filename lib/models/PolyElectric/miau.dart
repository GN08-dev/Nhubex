import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/mes_dropdowmn_button.dart';
import 'package:fl_chart/fl_chart.dart'; // Asegúrate de importar el paquete para el gráfico de barras

class GraphBar extends StatefulWidget {
  const GraphBar({super.key});

  @override
  State<GraphBar> createState() => _GraphBarState();
}

class _GraphBarState extends State<GraphBar> {
  dynamic? datosTemporales;
  bool loading = false;
  String selectedMes = '1';

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
    getData(selectedMes);
  }

  Future<void> getData(String selectedMes) async {
    setState(() {
      loading = true;
    });
    try {
      final response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/PE?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%22Mes%22:%22$selectedMes%22%7D%7D&format=JSON&isFront=true',
      );
      if (response.statusCode == 200) {
        setState(() {
          datosTemporales = json.decode(response.data);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error: $e');
    }
  }

  // Método para calcular el total de ventas por sucursal
  Map<String, double> calcularTotalVentas() {
    Map<String, double> totalVentasPorSucursal = {};

    if (datosTemporales != null && datosTemporales is List) {
      for (var registro in datosTemporales) {
        String nombreSucursal = registro['Nombre'];
        double valorNeto = double.tryParse(registro['ValorNeto']) ?? 0;

        if (totalVentasPorSucursal.containsKey(nombreSucursal)) {
          totalVentasPorSucursal[nombreSucursal] =
              (totalVentasPorSucursal[nombreSucursal] ?? 0) + valorNeto;
        } else {
          totalVentasPorSucursal[nombreSucursal] = valorNeto;
        }
      }
    }

    return totalVentasPorSucursal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Ventas - '),
            MesDropdownButton(
              meses: meses,
              selectedMes: selectedMes,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMes = newValue;
                  });
                  getData(selectedMes);
                }
              },
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
                  : Text(datosTemporales?.toString() ??
                      'No hay datos'), // Mostrar datos temporales
              // Mostrar solo ciertos datos
              ...calcularTotalVentas().entries.map((entry) {
                return ListTile(
                  title: Text(entry.key), // Nombre de la sucursal
                  subtitle:
                      Text('Total Ventas: ${entry.value}'), // Total de ventas
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
