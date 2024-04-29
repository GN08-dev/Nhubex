import 'package:flutter/material.dart';
import 'package:flutter_proyect/Pruebas/prueba.dart';
import 'package:flutter_proyect/Pruebas/prueba2.dart';
import 'package:flutter_proyect/models/Ventas/Venta_Consolidada_Rango_Fechas.dart';
import 'package:flutter_proyect/models/Ventas/Venta_Forma_Pago_Detalle.dart';
import 'package:flutter_proyect/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_proyect/src/Menu_Principa.dart';
import 'package:flutter_proyect/src/login.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';

void main() async {
  Intl.defaultLocale = 'es_MX';
  initializeDateFormatting('es_MX', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NHUBEX',
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
        home: Prueba2());
  }
}
