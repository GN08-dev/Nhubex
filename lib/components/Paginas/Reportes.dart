import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/components/ContenedorMain/Reportes.dart';
// ignore: unused_import
import 'package:flutter_proyect/models/Contenedor_imagenes/EmpresaImageHelper.dart';

class ReportesMain extends StatefulWidget {
  final String companyName;

  const ReportesMain({super.key, required this.companyName});

  @override
  State<ReportesMain> createState() => _ReportesMainState();
}

class _ReportesMainState extends State<ReportesMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawerScrimColor: Colors.transparent,
      drawer: SideMenu(
        companyName: widget.companyName,
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text(
          'Inicio',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: ReportesDelMesActual(companyName: widget.companyName),
              ),
            )
          ],
        ),
      ),
    );
  }
}
