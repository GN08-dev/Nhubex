import 'package:flutter/material.dart';
import 'package:flutter_proyect/models/PolyElectric/ventas1.dart';
import 'package:flutter_proyect/models/PolyElectric/Page2.dart';
import 'package:flutter_proyect/models/PolyElectric/Page3.dart';
import 'package:flutter_proyect/models/PolyElectric/graph.ventas.dart';

class HomePage1 extends StatefulWidget {
  const HomePage1({super.key});

  @override
  State<HomePage1> createState() => _HomePage1State();
}

class _HomePage1State extends State<HomePage1>
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
        backgroundColor:
            Color.fromARGB(255, 55, 70, 238), // Color de fondo del AppBar
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
                child: Center(child: Text('primera')),
              ),
            ),
            SizedBox(
              width: 80, // Ancho adecuado para la pestaña
              child: Center(child: Text('segunda')),
            ),
            SizedBox(
              width: 80, // Ancho adecuado para la pestaña
              child: Center(child: Text('tercera')),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: const [
          Ventas1(),
          Pagina2(),
          Pagina3(),
        ],
      ),
    );
  }
}
