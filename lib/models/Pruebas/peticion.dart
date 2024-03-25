import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeticionVentas extends StatefulWidget {
  const PeticionVentas({super.key});

  @override
  State<PeticionVentas> createState() => _PeticionVentasState();
}

class _PeticionVentasState extends State<PeticionVentas> {
  List<dynamic> datosTemporales = [];
  bool loading = false;
  String selectedMes = '1';
  String selectedMesAnterior = '1';

  final Map<String, String> meses = {
    'Enero': '1',
    'Febrero': '2',
    'Marzo': '3',
    'Abril': '4',
    'Mayo': '5',
    'Junio': '6',
    'Julio': '7',
    'Agosto': '8',
    'Septiembre': '9',
    'Octubre': '10',
    'Noviembre': '11',
    'Diciembre': '12',
  };

  @override
  void initState() {
    super.initState();
    loadSelectedMes();
  }

  Future<void> loadSelectedMes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMes = prefs.getString('selectedMes');
    if (savedMes != null) {
      setState(() {
        selectedMes = savedMes;
      });
      getData(selectedMes);
    }
  }

  Future<void> getData(String selectedMes) async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      // Limpiar el caché del mes anterior si existe
      await prefs.remove('cachedData_$selectedMesAnterior');

      String empresa =
          ''; // Obtener la empresa del usuario, por ejemplo, desde SharedPreferences

      String baseUrl = '';
      if (empresa == 'pe') {
        baseUrl =
            'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/PE';
      } else if (empresa == 've') {
        baseUrl =
            'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/VE';
      } else if (empresa == 'otra1') {
        baseUrl =
            'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/OTRA1';
      } else if (empresa == 'otra2') {
        baseUrl =
            'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/OTRA2';
      } else {
        throw Exception('Empresa no válida');
      }

      final response = await Dio().get(
        '$baseUrl?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%22Mes%22:%22$selectedMes%22%7D%7D&format=JSON&isFront=true',
      );
      if (response.statusCode == 200) {
        setState(() {
          datosTemporales = json.decode(response.data)["RESPUESTA"]["registro"];
          loading = false;
          selectedMesAnterior = selectedMes;
        });

        prefs.setString('selectedMes', selectedMes);
      } else {
        setState(() {
          loading = false;
        });
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
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
      appBar: AppBar(
        title: Text('Ventas'),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: _buildDataWidgets(datosTemporales),
            ),
    );
  }
}
