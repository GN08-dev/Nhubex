import 'package:flutter/material.dart';
import 'package:flutter_proyect/src/Menu_Principal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_proyect/models/Contenedor_imagenes/EmpresaImageHelper.dart';

class MyAppForm extends StatefulWidget {
  const MyAppForm({super.key});

  @override
  State<MyAppForm> createState() => _MyAppFormState();
}

class _MyAppFormState extends State<MyAppForm> {
  final empresaController = TextEditingController();
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  late FocusNode empresaFocusNode;
  late FocusNode usuarioFocusNode;
  late FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    empresaFocusNode = FocusNode();
    usuarioFocusNode = FocusNode();
    passwordFocusNode = FocusNode();

    empresaController.addListener(actualizarImagen);
  }

  @override
  void dispose() {
    empresaController.dispose();
    empresaFocusNode.dispose();
    usuarioController.dispose();
    passwordController.dispose();
    usuarioFocusNode.dispose();
    passwordFocusNode.dispose();

    super.dispose();
  }

  void actualizarImagen() {
    setState(() {});
  }

  Future<void> iniciarSesion() async {
    String empresa = empresaController.text;
    String usuario = usuarioController.text;
    String password = passwordController.text;

    if (empresa.isEmpty || usuario.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Favor de llenar el formulario'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              )
            ],
          );
        },
      );
    } else if (!EmpresaImageHelper.empresaSiglas
        .containsKey(empresa.toLowerCase())) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Empresa no válida'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              )
            ],
          );
        },
      );
    } else {
      try {
        // Iniciar sesión con Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: usuario,
          password: password,
        );

        // Verificar si la autenticación fue exitosa
        if (userCredential.user != null) {
          // Navegar al menú principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenu(
                  companyName: EmpresaImageHelper.getCompanyName(empresa)),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text('Credenciales inválidas'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ok'),
                  )
                ],
              );
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(e.message ?? 'Ocurrió un error'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'),
                )
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 100.0,
                backgroundColor: Colors.white,
                child: Image.network(
                    EmpresaImageHelper.getImageUrl(empresaController.text)),
              ),
              const Text(
                'Login',
                style: TextStyle(fontFamily: 'Lato', fontSize: 30.0),
              ),
              const SizedBox(
                width: 150.0,
                height: 15.0,
                child: Divider(color: Color.fromARGB(255, 77, 161, 201)),
              ),
              // Empresa
              TextFormField(
                controller: empresaController,
                focusNode: empresaFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Empresa',
                  labelText: 'Empresa',
                  suffixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(usuarioFocusNode);
                },
              ),
              const SizedBox(height: 18.0),
              // Usuario
              TextFormField(
                controller: usuarioController,
                focusNode: usuarioFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Correo electrónico',
                  labelText: 'Correo electrónico',
                  suffixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(passwordFocusNode);
                },
              ),
              // Contraseña
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                enableInteractiveSelection: false,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Contraseña',
                  labelText: 'Contraseña',
                  suffixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
              ),
              const SizedBox(height: 18.0),
              ElevatedButton(
                onPressed: iniciarSesion,
                child: const Text('Iniciar sesión'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
