import 'package:flutter/material.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/botones/custom_button.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/botones/TitulosBotones_Reportes.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/botones/navegador.dart';

class Reportesct extends StatefulWidget {
  const Reportesct({super.key});

  @override
  State<Reportesct> createState() => _ReportesctState();
}

class _ReportesctState extends State<Reportesct> {
  bool _showAdditionalButtonsInventario = false;
  bool _showAdditionalButtonsMonitoreo = false;
  bool _showAdditionalButtonsVentas = false;
  bool _showAdditionalButtonsOtros = false;

  // Función para crear una columna de botones adicionales de acuerdo con los datos proporcionados
  Widget _createButtonColumn(List<Map<String, dynamic>> buttons) {
    return Column(
      children: buttons.map((buttonData) {
        return CustomButtondes(
          title: buttonData['title'],
          onPressed: () {
            Reportes.handleButtonTap(context, buttonData);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomButtonReportes(
          title: 'Inventario',
          imagePath: 'assets/images/inventario.png',
          onPressed: () {
            setState(() {
              _showAdditionalButtonsInventario =
                  !_showAdditionalButtonsInventario;
            });
          },
        ),
        Visibility(
          visible: _showAdditionalButtonsInventario,
          child: _createButtonColumn(ButtonDataProvider.getInventoryButtons()),
        ),
        const SizedBox(height: 10),

        // Botón de Monitoreo con control de visibilidad de botones adicionales
        CustomButtonReportes(
          title: 'Monitoreo',
          imagePath: 'assets/images/supervision.png',
          onPressed: () {
            setState(() {
              _showAdditionalButtonsMonitoreo =
                  !_showAdditionalButtonsMonitoreo;
            });
          },
        ),
        Visibility(
          visible: _showAdditionalButtonsMonitoreo,
          child: _createButtonColumn(ButtonDataProvider.getMonitoringButtons()),
        ),
        const SizedBox(height: 10),

        // Botón de Ventas con control de visibilidad de botones adicionales
        CustomButtonReportes(
          title: 'Ventas',
          imagePath: 'assets/images/ventas.png',
          onPressed: () {
            setState(() {
              _showAdditionalButtonsVentas = !_showAdditionalButtonsVentas;
            });
          },
        ),
        Visibility(
          visible: _showAdditionalButtonsVentas,
          child: _createButtonColumn(ButtonDataProvider.getSalesButtons()),
        ),
        const SizedBox(height: 10),

        // Botón de Otros con control de visibilidad de botones adicionales
        CustomButtonReportes(
          title: 'Otros',
          imagePath: 'assets/images/mas.png',
          onPressed: () {
            setState(() {
              _showAdditionalButtonsOtros = !_showAdditionalButtonsOtros;
            });
          },
        ),
        Visibility(
          visible: _showAdditionalButtonsOtros,
          child: _createButtonColumn(ButtonDataProvider.getOtherButtons()),
        ),
      ],
    );
  }
}
