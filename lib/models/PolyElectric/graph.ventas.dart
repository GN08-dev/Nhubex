import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Ventas extends StatefulWidget {
  const Ventas({Key? key});

  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  List<dynamic> datosTemporales = []; // Cambiado a una lista vacía inicialmente
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

      final response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/PE?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%22Mes%22:%22$selectedMes%22%7D%7D&format=JSON&isFront=true',
      );
      if (response.statusCode == 200) {
        // Actualizar los datos temporales con los nuevos datos
        setState(() {
          datosTemporales = json.decode(response.data)["RESPUESTA"]["registro"];
          loading = false;
        });

        // Guardar el nuevo mes seleccionado
        setState(() {
          selectedMesAnterior = selectedMes;
        });

        // Guardar el mes seleccionado
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
        title: Row(
          children: [
            const Text('Ventas - '),
            DropdownButton<String>(
              value: selectedMes,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedMes = newValue;
                  });
                  getData(selectedMes);
                }
              },
              items: meses.entries.map<DropdownMenuItem<String>>((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList(),
            )
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.black,
            height: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              loading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        if (datosTemporales.isNotEmpty)
                          ..._buildDataWidgets(datosTemporales),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
