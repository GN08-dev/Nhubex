import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesBarChart extends StatelessWidget {
  final List<BarChartGroupData> seriesList;
  final List<String> xTitles;

  const SalesBarChart(this.seriesList, this.xTitles, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcular el ancho máximo de las etiquetas del eje Y
    double maxYLabelWidth = 0.0;
    List<double> yValues = [];
    for (var group in seriesList) {
      yValues.addAll(group.barRods.map((rod) => rod.toY).toList());
    }

// Verificar si yValues está vacío
    if (yValues.isNotEmpty) {
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
    }

// Calcular el alto máximo de las etiquetas del eje Y
    double maxYLabelHeight = 0.0;
    if (yValues.isNotEmpty) {
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
        maxYLabelHeight = max(maxYLabelHeight, textPainter.height);
      }
    }

// Calcular el número de dígitos en el número más grande
    int maxDigits = 1;
    if (yValues.isNotEmpty) {
      int maxNumber = yValues.map((value) => value.toInt()).reduce(max);
      while (maxNumber >= 10) {
        maxNumber ~/= 10;
        maxDigits++;
      }
    }

// Ajustar el tamaño del espacio reservado para las etiquetas del eje Y
    double reservedWidth = maxYLabelWidth + 16.0; // Ajustar según sea necesario
    double reservedHeight =
        maxDigits * maxYLabelHeight * 1.5; // Ajustar según sea necesario

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
              reservedSize: reservedWidth,
              getTitlesWidget: (value, meta) {
                int index = yValues.indexOf(value.toDouble());

                if (index == 0 ||
                    index == (xTitles.length - 1) ~/ 2 ||
                    index == xTitles.length - 1) {
                  String formatValue(double value) {
                    double scale = 250;
                    double roundedValue = (value / scale).round() * scale;
                    if (roundedValue >= 1000) {
                      return '${(roundedValue / 1000).toStringAsFixed(0)}K';
                    }
                    return roundedValue.toStringAsFixed(0);
                  }

                  return SizedBox(
                    height: 20, // Ajustar el alto según sea necesario
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 2), // Espacio fijo de 2
                      child: Text(
                        formatValue(value),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  );
                }
                return const SizedBox
                    .shrink(); // Ocultar el resto de las etiquetas
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
