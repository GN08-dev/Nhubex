import 'package:flutter/material.dart';
import 'package:flutter_proyect/models/Ventas/Filter_Week.dart';
import 'package:flutter_proyect/models/Ventas/Today.dart';
import 'package:flutter_proyect/models/Ventas/MesVentas.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: 3, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
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
        children: const [DiaVentas(), VentasXSemana(), MesVentas()],
      ),
    );
  }
}
