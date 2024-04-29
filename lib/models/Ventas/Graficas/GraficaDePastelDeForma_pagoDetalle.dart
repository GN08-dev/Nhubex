import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GreaficaDePastel extends StatefulWidget {
  final Map<String, double> totalVentaGeneral;
  final List<String> formasDePago;
  final List<Color> pastelColors = [
    Color(0xFF2196F3),
    Color(0xFFFFC300),
    Color(0xFFFF683B),
    Color(0xFF3BFF49),
    Color(0xFF6E1BFF),
    Color(0xFFFF3AF2),
    Color(0xFFE80054),
    Color(0xFF50E4FF),
    Color(0xFFFFD180),
    Color(0xFF006064),
    Color(0xFF84FFFF),
    Color(0xFF18FFFF),
    Color(0xFF00E5FF),
    Color(0xFF00B8D4),
    Color(0xFF009688),
    Color(0xFF004D40),
    Color(0xFF1DE9B6),
    Color(0xFF00BFA5),
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];

  GreaficaDePastel({
    Key? key,
    required this.totalVentaGeneral,
    required this.formasDePago,
  }) : super(key: key);

  @override
  _GreaficaDePastelState createState() => _GreaficaDePastelState();
}

class _GreaficaDePastelState extends State<GreaficaDePastel> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: Container(
            width: double.infinity,
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
                borderData: FlBorderData(show: false),
                centerSpaceRadius: 0,
                sections: showingSections(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var formaPago in widget.formasDePago
                  .take(4)) // Mostrar solo las primeras 4 formas de pago
                _Legend(
                  color: _getColorForFormaPago(formaPago),
                  description: formaPago,
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return widget.formasDePago.take(4).map((formaPago) {
      // Tomar solo las primeras 5 formas de pago
      final double totalVenta = widget.totalVentaGeneral[formaPago] ?? 0.0;
      return PieChartSectionData(
        color: _getColorForFormaPago(formaPago),
        value: totalVenta,
        title: touchedIndex == widget.formasDePago.indexOf(formaPago)
            ? '${(totalVenta / 1000).toStringAsFixed(2)}k' // Convertir a miles y mostrar como k
            : '',
        titleStyle: TextStyle(
          fontSize: touchedIndex == widget.formasDePago.indexOf(formaPago)
              ? 16
              : 0, // Mostrar la etiqueta solo cuando se toca
          fontWeight: FontWeight.bold,
        ),
        radius: 120.0, // Ajustar el radio de las secciones
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Color _getColorForFormaPago(String formaPago) {
    int index =
        widget.formasDePago.indexOf(formaPago) % widget.pastelColors.length;
    return widget.pastelColors[index];
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

/*
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
*/