import 'package:flutter/material.dart';
import 'package:flutter_proyect/router/router.dart';
//import 'package:flutter_proyect/src/login.dart';
import 'package:flutter_proyect/container/Graficas/Grafica_anio.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NHUBEX',
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      home: Ventas_anio(),
    );
  }
}
