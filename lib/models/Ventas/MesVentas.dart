import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MesVentas extends StatefulWidget {
  const MesVentas({super.key});

  @override
  State<MesVentas> createState() => _MesVentasState();
}

class _MesVentasState extends State<MesVentas> {
  List<dynamic> datosTemporales = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getData(); // Llamar a la función para obtener datos al iniciar
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
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: _buildDataWidgets(datosTemporales),
              ),
            ),
    );
  }
}
