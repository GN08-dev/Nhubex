import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menu_inicio_Administrador/Menu_Principal_Administrador.dart';
import 'package:flutter_proyect/models/Contenedor_imagenes/EmpresaImageHelper.dart';
import 'package:flutter_proyect/src/Menu_Principal/Menus_Inicio_Usuario/Menu_Principal_Usuarios.dart';
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

    // Llamar a obtenerDatosUsuario dentro de un bloque async
    obtenerDatosUsuario().then((datosUsuario) {
      if (datosUsuario['nombre'] != null) {
        // Redirigir según el rol
        if (datosUsuario['rol'] == 'usuario') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Menu_Principal_Usuarios(
                  companyName: datosUsuario['empresa']!),
            ),
          );
        } else {
          if (empresaController.text.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Menu_Principal_Administrador(
                    companyName: empresaController.text),
              ),
            );
          }
        }
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
          // Captura el UID del usuario autenticado
          String uid = userCredential.user!.uid;
          //String mydocID = 'user.uid';

          // Imprime el UID
          print('UID del usuario autenticado: $uid');

          // Obtener información del usuario de Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(userCredential.user!.uid)
              .get();
          print('DocumentSnapshot del usuario: ${userDoc.data()}');

          if (userDoc.exists) {
            // Verificar el rol del usuario
            String rol = userDoc['rol'];
            String nombre = userDoc['Nombre'];
            String empresaSiglas = userDoc['empresa'];
            print('Empresa del usuario: $empresaSiglas');

            if (rol == 'usuario' || rol == 'Admin') {
              // Obtener el valor de empresa siglas
              String empresaFinal = empresaSiglas.isNotEmpty
                  ? empresaSiglas
                  : empresaController.text;

              // Guardar los datos del usuario en SharedPreferences
              await guardarDatosUsuario(uid, nombre, rol, empresaFinal);
              // Redirigir según el rol
              if (rol == 'usuario') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Menu_Principal_Usuarios(companyName: empresaSiglas),
                  ),
                );
              } else if (rol == 'Admin') {
                if (empresaSiglas == null || empresaSiglas.isEmpty) {
                  empresaSiglas = empresaController.text;
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Menu_Principal_Administrador(
                        companyName: empresaSiglas),
                  ),
                );
              }
            } else {
              mostrarAlerta('Error',
                  'No tienes los permisos necesarios para iniciar sesión.');
            }
          } else {
            mostrarAlerta('Error', 'Usuario no encontrado');
          }
        } else {
          mostrarAlerta('Error', 'Credenciales inválidas');
        }
      } on FirebaseAuthException catch (e) {
        mostrarAlerta('Error', e.message ?? 'Ocurrió un error');
      } catch (e) {
        mostrarAlerta('Error', 'Ocurrió un error inesperado');
      }
    }
  }

  Future<void> guardarDatosUsuario(
      String uid, String nombre, String rol, String empresaSiglas) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('Nombre', nombre);
    await prefs.setString('rol', rol);
    await prefs.setString('empresa', empresaSiglas);
  }

  Future<Map<String, String?>> obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? uid = prefs.getString('uid');
    String? nombre = prefs.getString('Nombre');
    String? rol = prefs.getString('rol');
    String? empresaSiglas = prefs.getString('empresa');

    return {
      'uid': uid,
      'nombre': nombre,
      'rol': rol,
      'empresa': empresaSiglas,
    };
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
