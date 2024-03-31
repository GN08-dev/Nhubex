import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:intl/intl.dart';

class MesVentas extends StatefulWidget {
  final String companyName;

  const MesVentas({Key? key, required this.companyName}) : super(key: key);

  @override
  _MesVentasState createState() => _MesVentasState();
}

class _MesVentasState extends State<MesVentas> {
  bool loading = false;
  double totalValorNetoSemana = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';
  double totalVentasMejorVendedor = 0.0; // Total de ventas del mejor vendedor
  late List<dynamic> datosTemporales;
  late List<double> ventasPorDiaList = List.filled(7, 0.0);
  late int currentDayOfWeek;
  late List<String> sucursalesDisponibles = [];
  String selectedSucursal = '';

  @override
  void initState() {
    super.initState();
    currentDayOfWeek = DateTime.now().weekday;
    getData();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    try {
      Response response;
      if (widget.companyName == 'POLY ELECTRIC') {
        response = await Dio().get(
          'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
        );
      } else {
        response = await Dio().get(
          'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
        );
      }

      if (response.statusCode == 200) {
        datosTemporales = json.decode(response.data)["RESPUESTA"]["registro"];
        sucursalesDisponibles = obtenerSucursales(datosTemporales);
        if (sucursalesDisponibles.isNotEmpty) {
          selectedSucursal = sucursalesDisponibles.first;
        }
        calculateData();
        setState(() {
          loading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      print('Error: $e');
    }
  }

  List<String> obtenerSucursales(List<dynamic> datos) {
    Set<String> sucursales = {};
    datos.forEach((registro) {
      String nombre = registro["Nombre"];
      sucursales.add(nombre);
    });
    return ['Todas las Sucursales', ...sucursales.toList()];
  }

  void calculateData() {
    // Obtener la fecha actual
    DateTime now = DateTime.now();

    // Obtener el primer día de la semana (lunes)
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Filtrar los datos de la última semana y la sucursal seleccionada
    List<dynamic> datosSemana = datosTemporales.where((registro) {
      // Convertir la fecha del registro a DateTime
      DateTime fecha = DateTime.parse(registro["Fecha"]);
      // Verificar si la fecha está dentro de la última semana
      return fecha.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          (selectedSucursal == 'Todas las Sucursales' ||
              registro['Nombre'] == selectedSucursal);
    }).toList();

    // Inicializar el arreglo de datos para la gráfica
    ventasPorDiaList = List.filled(7, 0.0);

    // Inicializar el mapa para almacenar los totales por día
    Map<String, double> ventasPorDia = {};

    // Procesar los datos de la semana
    datosSemana.forEach((registro) {
      dynamic valorNetoData = registro['ValorNeto'];
      if (valorNetoData != null) {
        double valorNeto = double.parse(valorNetoData);
        dynamic fechaData = registro['Fecha'];
        if (fechaData != null) {
          DateTime date = DateTime.parse(fechaData);
          int day = date.weekday;
          // Sumar el valor neto al día correspondiente
          ventasPorDiaList[day - 1] +=
              valorNeto; // Restamos 1 para que los días se alineen correctamente
          // Guardar el total por día en el mapa
          String formattedDate = DateFormat('yyyy-MM-dd').format(date);
          ventasPorDia[formattedDate] =
              (ventasPorDia[formattedDate] ?? 0) + valorNeto;
        }
      }
    });

    // Calcular el total del valor neto de la semana
    totalValorNetoSemana = ventasPorDiaList.fold(
        0.0, (previousValue, element) => previousValue + element);

    // Encontrar la sucursal con más ventas
    Map<String, double> ventasPorSucursal = {};
    datosSemana.forEach((registro) {
      dynamic valorNetoData = registro['ValorNeto'];
      if (valorNetoData != null) {
        double valorNeto = double.parse(valorNetoData);
        String sucursal = registro['Nombre'];
        ventasPorSucursal[sucursal] =
            (ventasPorSucursal[sucursal] ?? 0) + valorNeto;
      }
    });
    mejorSucursal = ventasPorSucursal.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Encontrar el mejor vendedor de la mejor sucursal
    List vendedoresMejorSucursal = datosSemana
        .where((registro) => registro["Nombre"] == mejorSucursal)
        .map((registro) => registro["Vendedor"])
        .toList();
    Map<String, int> conteoVendedores = {};
    vendedoresMejorSucursal.forEach((vendedor) {
      conteoVendedores[vendedor] = (conteoVendedores[vendedor] ?? 0) + 1;
    });
    mejorVendedor = conteoVendedores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Encontrar el total de ventas del mejor vendedor
    totalVentasMejorVendedor = datosSemana
        .where((registro) =>
            registro["Nombre"] == mejorSucursal &&
            registro["Vendedor"] == mejorVendedor)
        .map((registro) => double.parse(registro["ValorNeto"] ?? '0'))
        .fold(0, (previousValue, valorNeto) => previousValue + valorNeto);
  }

  @override
  Widget build(BuildContext context) {
    String currentMonth = DateFormat('MMMM').format(DateTime.now());

    // ignore: unused_local_variable
    double maxValue = 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            DropdownButton<String>(
              value: selectedSucursal,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSucursal = newValue!;
                  calculateData();
                });
              },
              items: sucursalesDisponibles
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.zero,
                color: Colors.grey.withOpacity(0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      currentMonth,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalValorNetoSemana.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 1.70,
                      child: Padding(
                        padding: EdgeInsets.zero,
                        child: SalesLineChart(
                          _createSampleData(),
                          animate: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildContainerWithBackground(
                      child: Row(children: [
                        const Icon(
                          Icons.attach_money,
                          size: 45,
                          color: Color.fromARGB(255, 2, 128, 8),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Venta total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '\$${totalValorNetoSemana.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 15),
                    _buildContainerWithBackground(
                      child: Row(children: [
                        const Icon(
                          Icons.location_on,
                          size: 45,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedSucursal == 'Todas las Sucursales'
                              ? 'Suc.Estrella'
                              : 'Sucursal',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '$mejorSucursal',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 15),
                    _buildContainerWithBackground(
                      child: Row(children: [
                        const Icon(
                          Icons.star_border_purple500_outlined,
                          size: 45,
                          color: Color.fromARGB(255, 249, 168, 37),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Mejor vendedor',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Text(
                          '$mejorVendedor',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 15),
                    _buildContainerWithBackground(
                      child: Row(children: [
                        const Icon(
                          Icons.shopping_cart,
                          size: 45,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Ventas',
                          style: TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                        Text(
                          '\$${totalVentasMejorVendedor.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        )
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildContainerWithBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.8),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
      padding: const EdgeInsets.all(8),
    );
  }

  List<charts.Series<SalesData, int>> _createSampleData() {
    final data = List.generate(7, (index) {
      return SalesData(
          index + 1,
          ventasPorDiaList[
              index]); // Sumamos 1 para que los días comiencen desde 1
    });

    final filteredData = data.where((element) => element.sales > 0.0).toList();

    return [
      charts.Series<SalesData, int>(
        id: 'Sales',
        domainFn: (SalesData sales, _) => sales.day,
        measureFn: (SalesData sales, _) => sales.sales,
        data: filteredData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        strokeWidthPxFn: (_, __) => 4,
        radiusPxFn: (_, __) => 3,
        labelAccessorFn: (SalesData sales, _) =>
            '${sales.day}\n\$${sales.sales.toStringAsFixed(2)}',
      )
    ];
  }
}

class SalesData {
  final int day;
  final double sales;

  SalesData(this.day, this.sales);
}

class SalesLineChart extends StatelessWidget {
  final List<charts.Series<SalesData, int>> seriesList;
  final bool animate;

  SalesLineChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    double maxValue = 0.0; // Valor inicial

    if (seriesList.isNotEmpty) {
      // Si seriesList no está vacía, se puede calcular el valor máximo
      maxValue = seriesList
          .expand((series) => series.data.map((data) => data.sales))
          .reduce((value, element) => value > element ? value : element);
    }

    return charts.LineChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: const charts.NumericAxisSpec(
        renderSpec: charts.NoneRenderSpec(),
      ),
      domainAxis: const charts.NumericAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 14,
            color: charts.MaterialPalette.black,
          ),
        ),
      ),
    );
  }
}
