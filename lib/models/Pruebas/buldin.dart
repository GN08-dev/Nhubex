import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_proyect/components/Button/Sucursales.dart';
import 'package:flutter_proyect/components/Graph/Grafica_linea.dart';

class MesBuild extends StatefulWidget {
  const MesBuild({Key? key}) : super(key: key);

  @override
  _MesBuildState createState() => _MesBuildState();
}

class _MesBuildState extends State<MesBuild> {
  List<dynamic> datosTemporales = [];
  bool loading = false;
  double totalValorNeto = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
      );
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            datosTemporales =
                json.decode(response.data)["RESPUESTA"]["registro"];
            loading = false;
            // Calcular suma del valor neto, mejor sucursal y mejor vendedor
            calculateData();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            loading = false;
          });
        }
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
      print('Error: $e');
    }
  }

  void calculateData() {
    // Sumar el valor neto
    totalValorNeto = datosTemporales.fold(
        0.0, (sum, item) => sum + double.parse(item["ValorNeto"].toString()));

    // Encontrar la mejor sucursal
    final sucursales = datosTemporales.map((item) => item["Nombre"]).toList();
    final sucursalCount = Map<String, int>();
    sucursales.forEach((sucursal) => sucursalCount[sucursal] =
        sucursalCount.containsKey(sucursal) ? sucursalCount[sucursal]! + 1 : 1);
    mejorSucursal =
        sucursalCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Encontrar el mejor vendedor de la mejor sucursal
    final vendedores = datosTemporales
        .where((item) => item["Nombre"] == mejorSucursal)
        .map((item) => item["Vendedor"])
        .toList();
    final vendedorCount = Map<String, int>();
    vendedores.forEach((vendedor) => vendedorCount[vendedor] =
        vendedorCount.containsKey(vendedor) ? vendedorCount[vendedor]! + 1 : 1);
    mejorVendedor =
        vendedorCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  List<Widget> _buildDataWidgets(List<dynamic> data) {
    return data.map<Widget>((registro) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fecha: ${registro["Fecha"]}'),
                Text('Descripcion: ${registro["Descripcion"]}'),
                Text('IdDiario: ${registro["IdDiario"]}'),
                Text('IDHub: ${registro["IDHub"]}'),
                Text('IdM3: ${registro["IdM3"]}'),
                Text('IdTrx: ${registro["IdTrx"]}'),
                Text('NDoc: ${registro["NDoc"]}'),
                Text('NOM_Cliente: ${registro["NOM_Cliente"]}'),
                Text('Nombre: ${registro["Nombre"]}'),
                Text('TMIdProceso: ${registro["TMIdProceso"]}'),
                Text('UUID: ${registro["UUID"]}'),
                Text('Valor: ${registro["Valor"]}'),
                Text('ValorNeto: ${registro["ValorNeto"]}'),
                Text('Vendedor: ${registro["Vendedor"]}'),
                Text('Vendedor2: ${registro["Vendedor2"]}'),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 300,
                    color: Colors.white,
                    child: LineChartSample2(),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Widget para seleccionar la sucursal
                        const SucursalWidget(),
                        const SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Total Valor Neto: $totalValorNeto',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Sucursal Estrella: $mejorSucursal',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Mejor vendedor de sucursal: $mejorVendedor',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                  // Datos de ventas
                  //..._buildDataWidgets(datosTemporales),
                ],
              ),
            ),
    );
  }
}
