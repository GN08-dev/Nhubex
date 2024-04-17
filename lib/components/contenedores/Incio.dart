// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/botones/custom_button.dart';
import 'package:flutter_proyect/Pruebas/test.dart';
import 'package:flutter_proyect/models/Reportes/Reportes.dart';
import 'package:flutter_proyect/models/prenomina/prenomina.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeInfo extends StatelessWidget {
  final String companyName;

  const WelcomeInfo({super.key, required this.companyName});

  Future<String?> obtenerCompanyName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre_empresa');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        CustomButton(
          title: 'Pruebas',
          imagePath: 'assets/images/prueba.png',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TestPrueba2(),
              ),
            );
          },
          additionalText: 'Testeo de pruebas',
        ),
        const SizedBox(height: 10),
        CustomButton(
          title: 'Ventas',
          imagePath: 'assets/images/diagrama.png',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportesMain(companyName: ''),
              ),
            );
          },
          additionalText:
              'En esta sección contamos con las ventas del mes actual y mes pasado.',
        ),

        ///un botton
        const SizedBox(height: 10),
        FutureBuilder<String?>(
          future: obtenerCompanyName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData) {
              return CustomButton(
                title: 'Prenomina',
                imagePath: 'assets/images/nomina.png',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Prenomina(companyName: snapshot.data!),
                    ),
                  );
                },
                additionalText: 'Prenomina de empleados',
              );
            } else {
              return CustomButton(
                title: 'Prenomina',
                imagePath: 'assets/images/nomina.png',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Prenomina(companyName: ''),
                    ),
                  );
                },
                additionalText: 'Prenomina de empleados',
              );
            }
          },
        ),
      ],
    );
  }
}
