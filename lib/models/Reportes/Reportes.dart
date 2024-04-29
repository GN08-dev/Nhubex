// ignore_for_file: file_names, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/components/contenedores/ReportesCt.dart';
// ignore: unused_import
import 'package:flutter_proyect/models/Contenedor_imagenes/EmpresaImageHelper.dart';

class ReportesMain extends StatefulWidget {
  const ReportesMain({super.key});

  @override
  State<ReportesMain> createState() => _ReportesMainState();
}

class _ReportesMainState extends State<ReportesMain> {
  String dropdownValue = 'Reportes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawerScrimColor: Colors.transparent,
      drawer: Menu_Lateral(),
      appBar: CustomAppBar(titleText: 'Reportes'),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: const Reportesct(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
