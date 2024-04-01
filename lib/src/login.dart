import 'package:flutter/material.dart';
import 'package:flutter_proyect/src/Menu_Principal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_proyect/models/Contenedor_imagenes/EmpresaImageHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppForm extends StatefulWidget {
  const MyAppForm({Key? key}) : super(key: key);

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

    // Llamar a obtenerNombreEmpresa dentro de un bloque async
    obtenerNombreEmpresa().then((nombreEmpresa) {
      if (nombreEmpresa != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainMenu(companyName: nombreEmpresa),
          ),
        );
      }
    });
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
      mostrarAlerta('Error', 'Favor de llenar el formulario');
    } else if (!EmpresaImageHelper.empresaSiglas
        .containsKey(empresa.toLowerCase())) {
      mostrarAlerta('Error', 'Empresa no válida');
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
          // Guardar el nombre de la empresa en SharedPreferences
          await guardarNombreEmpresa(
              EmpresaImageHelper.getCompanyName(empresa));

          // Navegar al menú principal
          String? nombreEmpresa = await obtenerNombreEmpresa();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainMenu(companyName: nombreEmpresa!),
            ),
          );
        } else {
          mostrarAlerta('Error', 'Credenciales inválidas');
        }
      } on FirebaseAuthException catch (e) {
        mostrarAlerta('Error', e.message ?? 'Ocurrió un error');
      }
    }
  }

  Future<void> guardarNombreEmpresa(String nombreEmpresa) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre_empresa', nombreEmpresa);
  }

  Future<String?> obtenerNombreEmpresa() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('nombre_empresa');
  }

  void mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
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
