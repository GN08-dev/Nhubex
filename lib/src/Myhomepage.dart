import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Graph/Grafica_linea.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi gráfico de línea'),
      ),
      body: const Center(
        child: LineChartSample2(),
      ),
    );
  }
}
