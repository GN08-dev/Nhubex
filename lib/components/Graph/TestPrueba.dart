import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_proyect/components/Graph/prueba.dart';

class TestPrueba extends StatefulWidget {
  const TestPrueba({Key? key}) : super(key: key);

  @override
  State<TestPrueba> createState() => _TestPruebaState();
}

class _TestPruebaState extends State<TestPrueba> {
  final List<FlSpot> spots = [
    FlSpot(0, 1),
    FlSpot(2.6, 2),
    FlSpot(4.9, 3),
    FlSpot(6.8, 4),
    FlSpot(8, 3),
    FlSpot(9.5, 2),
    FlSpot(11, 1),
  ];

  final List<Color> gradientColors = [
    Color(0xff6aa8fd),
    Color(0xff8fc0ff),
    Color(0xffa4a8fd),
  ];

  final List<String> monthTitles = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC'
  ];

  // Lista de valores para el eje Y
  final List<double> yValues = [1, 3, 5, 7, 9];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Prueba'),
      ),
      body: Center(
        child: LineChartSample3(
          spots: spots,
          gradientColors: gradientColors,
          monthTitles: monthTitles,
          yValues:
              yValues, // Pasamos la lista de valores para el eje Y al widget LineChartSample3
        ),
      ),
    );
  }
}
