import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/models/Pruebas/buldin.dart';
import 'package:flutter_proyect/models/Ventas/Filter_Week.dart';
import 'package:flutter_proyect/models/Ventas/Today.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<dynamic> datosTemporales = [];
  bool loading = false;
  double totalValorNeto = 0.0;
  String mejorSucursal = '';
  String mejorVendedor = '';
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
    getData();
    super.initState();
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300], // Cambio del color del AppBar
        title: const Text('appbar'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        centerTitle: true,
        elevation: 10,
        bottom: TabBar(
          indicatorColor: Colors.red,
          labelStyle: const TextStyle(color: Colors.black, fontSize: 18),
          unselectedLabelColor: Colors.white,
          unselectedLabelStyle: const TextStyle(fontSize: 16),
          controller: controller,
          tabs: const [
            Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: SizedBox(
                width: 80, // Ancho adecuado para la pestaña
                child: Center(child: Text('Dia')),
              ),
            ),
            SizedBox(
              width: 80, // Ancho adecuado para la pestaña
              child: Center(child: Text('Semana')),
            ),
            SizedBox(
              width: 80, // Ancho adecuado para la pestaña
              child: Center(child: Text('Mes')),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          DiaVentas(datosTemporales: datosTemporales),
          VentasXSemana(datosTemporales: datosTemporales),
          MesBuild(datosTemporales: datosTemporales),
          //MesVentas(datosTemporales: datosTemporales,)
        ],
      ),
    );
  }
}
