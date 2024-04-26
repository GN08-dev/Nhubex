import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Graficapastel extends StatelessWidget {
  const Graficapastel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      swapAnimationDuration: const Duration(milliseconds: 10),
      swapAnimationCurve: Curves.easeInOutQuint,
      PieChartData(
        sections: [
          PieChartSectionData(value: 200, color: Colors.blue),
          PieChartSectionData(value: 20, color: Colors.green),
          PieChartSectionData(value: 20, color: Colors.yellow),
          PieChartSectionData(value: 20, color: Colors.red),
        ],
      ),
    );
  }
}
