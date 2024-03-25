import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Paginas/home_page.dart';
import 'package:flutter_proyect/router/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_proyect/src/login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Usamos DefaultFirebaseOptions.currentPlatform según la documentación.
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
      home: MyAppForm(),
    );
  }
}
