import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GreaficaDePastel extends StatefulWidget {
  final double totalEfectivoVenta;
  final double totalTdcVenta;
  final double totalTddVenta;
  final double totalTickets;

  const GreaficaDePastel({
    Key? key,
    required this.totalEfectivoVenta,
    required this.totalTdcVenta,
    required this.totalTddVenta,
    required this.totalTickets,
  }) : super(key: key);

  @override
  State<GreaficaDePastel> createState() => _GreaficaDePastelState();
}

class _GreaficaDePastelState extends State<GreaficaDePastel> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: Container(
            width: double.infinity,
            height: 300, // Tamaño fijo para la gráfica de pastel
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                centerSpaceRadius: 0,
                sections: showingSections(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Legend(color: Colors.blue, description: 'Efectivo'),
              _Legend(color: Colors.green, description: 'TDC'),
              _Legend(color: Colors.yellow, description: 'TDD'),
              _Legend(color: Colors.red, description: 'Tickets'),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: widget.totalEfectivoVenta,
        title: touchedIndex == 0
            ? '${widget.totalEfectivoVenta.toStringAsFixed(2)}'
            : '',
        titleStyle: TextStyle(
          fontSize: touchedIndex == 0 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        radius: touchedIndex == 0 ? 110.0 : 100.0,
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.green,
        value: widget.totalTdcVenta,
        title: touchedIndex == 1
            ? '${widget.totalTdcVenta.toStringAsFixed(2)}'
            : '',
        titleStyle: TextStyle(
          fontSize: touchedIndex == 1 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        radius: touchedIndex == 1 ? 110.0 : 100.0,
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.yellow,
        value: widget.totalTddVenta,
        title: touchedIndex == 2
            ? '${widget.totalTddVenta.toStringAsFixed(2)}'
            : '',
        titleStyle: TextStyle(
          fontSize: touchedIndex == 2 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        radius: touchedIndex == 2 ? 110.0 : 100.0,
        titlePositionPercentageOffset: 0.6,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: widget.totalTickets,
        title: touchedIndex == 3
            ? '${widget.totalTickets.toStringAsFixed(2)}'
            : '',
        titleStyle: TextStyle(
          fontSize: touchedIndex == 3 ? 20.0 : 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        radius: touchedIndex == 3 ? 110.0 : 100.0,
        titlePositionPercentageOffset: 0.6,
      ),
    ];
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String description;

  const _Legend({
    Key? key,
    required this.color,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            description,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
