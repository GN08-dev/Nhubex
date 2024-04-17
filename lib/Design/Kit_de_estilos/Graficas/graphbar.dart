import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesBarChart extends StatelessWidget {
  final List<BarChartGroupData> seriesList;
  final List<String> xTitles;

  const SalesBarChart(this.seriesList, this.xTitles, {super.key});

  @override
  Widget build(BuildContext context) {
    // Calcular el ancho máximo de las etiquetas del eje Y
    double maxYLabelWidth = 0.0;
    List<double> yValues = [];
    for (var group in seriesList) {
      yValues.addAll(group.barRods.map((rod) => rod.toY).toList());
    }
    yValues = yValues.toSet().toList(); // Elimina duplicados
    for (double value in yValues) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      maxYLabelWidth = max(maxYLabelWidth, textPainter.width);
    }

    return BarChart(
      BarChartData(
        barGroups: seriesList,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Ajusta si es necesario
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < xTitles.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      xTitles[index],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize:
                  maxYLabelWidth + 16, // Agrega más espacio entre etiquetas
              getTitlesWidget: (value, meta) {
                // Función para formatear valores en miles
                String formatValue(double value) {
                  // Redondear a múltiplos de 250
                  double scale = 250;
                  double roundedValue = (value / scale).round() * scale;

                  // Mostrar el valor redondeado en miles (`K`) si es mayor o igual a 1000
                  if (roundedValue >= 1000) {
                    return '${(roundedValue / 1000).toStringAsFixed(0)}K';
                  }
                  // Mostrar el valor redondeado como número cerrado
                  return roundedValue.toStringAsFixed(0);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: Text(
                    formatValue(value),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.end,
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (BarChartGroupData group) =>
                const Color.fromARGB(255, 251, 252, 252),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toString(),
                const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
