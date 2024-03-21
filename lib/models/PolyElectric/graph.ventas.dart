import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/mes_dropdowmn_button.dart';

class Ventas extends StatefulWidget {
  const Ventas({super.key});

  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
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
      appBar: AppBar(
        title: Row(
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0), // Altura de la línea
          child: Container(
            color: Colors.black,
            height: 0.5, // Grosor de la línea
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
                  : Text(datos?.toString() ?? 'No hay datos'),
            ],
          ),
        ),
      ),
    );
  }
}
