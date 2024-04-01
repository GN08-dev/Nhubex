import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String companyName; // Nombre de la empresa

  const HomePage({super.key, required this.companyName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<dynamic> datosTemporales = [];
  bool loading = false;
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

    // ignore: unused_local_variable
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (widget.companyName == 'POLY ELECTRIC') {
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
      } else if (widget.companyName == 'VEANA') {
      } else if (widget.companyName == 'GTRIUNFO') {
      } else if (widget.companyName == 'NIETO') {
      } else if (widget.companyName == 'PAVEL') {
      } else if (widget.companyName == 'SHYLA') {
      } else if (widget.companyName == 'PBD5') {
      } else if (widget.companyName == 'CONTINIO') {
      } else {
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
      }

      if (datosTemporales.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Información'),
              content: Text(
                'Por el momento, no hay información disponible para los reportes de ${widget.companyName}.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
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
        backgroundColor: Colors.blue[300],
        title: Text(widget.companyName),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
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
                width: 80,
                child: Center(child: Text('Dia')),
              ),
            ),
            SizedBox(
              width: 80,
              child: Center(child: Text('Semana')),
            ),
            SizedBox(
              width: 80,
              child: Center(child: Text('Mes')),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [],
      ),
    );
  }
}