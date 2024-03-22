import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/mes_dropdowmn_button.dart';

class Ventas1 extends StatefulWidget {
  const Ventas1({Key? key});

  @override
  State<Ventas1> createState() => _Ventas1State();
}

class _Ventas1State extends State<Ventas1> {
  dynamic datos;
  bool loading = false;
  String selectedMes = '1'; // Valor inicial del mes

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
    getData(selectedMes); // Llamada inicial con el mes seleccionado
  }

  Future<void> getData(String selectedMes) async {
    setState(() {
      loading = true;
    });
    try {
      final response = await Dio().get(
          'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/PE?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%22Mes%22:%22$selectedMes%22%7D%7D&format=JSON&isFront=true');
      if (response.statusCode == 200) {
        setState(() {
          datos = response.data;
          loading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Peticion - '), // Texto estático
                MesDropdownButton(
                  meses: meses,
                  selectedMes: selectedMes,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedMes = newValue;
                      });
                      getData(selectedMes);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : Text(datos?.toString() ?? 'No hay datos'),
          ],
        ),
      ),
    );
  }
}
