import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Button/Sucursales.dart';
import 'package:flutter_proyect/components/Graph/Grafica_linea.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MesBuild extends StatefulWidget {
  final List<dynamic> datosTemporales;

  const MesBuild({super.key, required this.datosTemporales});

  @override
  _MesBuildState createState() => _MesBuildState();
}

class _MesBuildState extends State<MesBuild> {
  bool loading = false;
  double totalValorNeto = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';

  @override
  void initState() {
    super.initState();
    calculateData();
  }

  void calculateData() {
    // Sumar el valor neto
    totalValorNeto = widget.datosTemporales.fold(
        0.0, (sum, item) => sum + double.parse(item["ValorNeto"].toString()));

    // Encontrar la mejor sucursal
    final sucursales =
        widget.datosTemporales.map((item) => item["Nombre"]).toList();
    final sucursalCount = Map<String, int>();
    sucursales.forEach((sucursal) => sucursalCount[sucursal] =
        sucursalCount.containsKey(sucursal) ? sucursalCount[sucursal]! + 1 : 1);
    mejorSucursal =
        sucursalCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Encontrar el mejor vendedor de la mejor sucursal
    final vendedores = widget.datosTemporales
        .where((item) => item["Nombre"] == mejorSucursal)
        .map((item) => item["Vendedor"])
        .toList();
    final vendedorCount = Map<String, int>();
    vendedores.forEach((vendedor) => vendedorCount[vendedor] =
        vendedorCount.containsKey(vendedor) ? vendedorCount[vendedor]! + 1 : 1);
    mejorVendedor =
        vendedorCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
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
                    child: const LineChartSample2(),
                    // Puedes mostrar un gráfico o cualquier otro widget aquí
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
                ],
              ),
            ),
    );
  }
}
