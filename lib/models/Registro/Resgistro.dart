import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_proyect/Design/Kit_de_estilos/appbar/appbar_reportes.dart';
import 'package:flutter_proyect/components/Menu_Desplegable/Menu_Lateral.dart';
import 'package:flutter_proyect/models/Contenedor_imagenes/EmpresaImageHelper.dart';

class Registro extends StatefulWidget {
  final String companyName;
  const Registro({super.key, required this.companyName});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final empresaController = TextEditingController();
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();
  final rolController = TextEditingController();
  late FocusNode empresaFocusNode;
  late FocusNode usuarioFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode nombreFocusNode;
  late FocusNode rolFocusNode;

  String? selectedRole;

  @override
  void initState() {
    super.initState();
    empresaFocusNode = FocusNode();
    usuarioFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    nombreFocusNode = FocusNode();
    rolFocusNode = FocusNode();

    empresaController.addListener(actualizarImagen);
  }

  void actualizarImagen() {
    setState(() {});
  }

  @override
  void dispose() {
    empresaController.dispose();
    nombreController.dispose();
    usuarioController.dispose();
    passwordController.dispose();
    empresaFocusNode.dispose();
    nombreFocusNode.dispose();
    usuarioFocusNode.dispose();
    passwordFocusNode.dispose();
    rolFocusNode.dispose();
    super.dispose();
  }

  Future<void> registrarUsuario() async {
    String empresa = empresaController.text;
    String usuario = usuarioController.text;
    String password = passwordController.text;
    String nombre = nombreController.text;
    String? rol = selectedRole;

    if (empresa.isEmpty && rol == 'usuario' ||
        usuario.isEmpty ||
        password.isEmpty ||
        nombre.isEmpty ||
        rol == null) {
      mostrarAlerta('Error', 'Favor de llenar el formulario');
    } else {
      try {
        // Registrar el usuario con Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usuario,
          password: password,
        );

        // Verificar si el registro fue exitoso
        if (userCredential.user != null) {
          // Obtener el UID del usuario registrado
          final uid = userCredential.user!.uid;

          // Crear un mapa de datos para el usuario
          final userData = {
            'nombre': nombre,
            'correo': usuario,
            'rol': rol,
          };

          // Si el rol del usuario no es admin, incluir el campo 'empresa'
          if (rol != 'admin') {
            userData['empresa'] = empresa;
          }

          // Guardar los datos en Cloud Firestore bajo la colección 'usuarios' y el documento con el UID del usuario
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .set(userData);

          // Mostrar mensaje de éxito
          mostrarAlerta('Éxito', 'Usuario registrado con éxito');
        } else {
          mostrarAlerta('Error', 'Error en el registro');
        }
      } on FirebaseAuthException catch (e) {
        mostrarAlerta('Error', e.message ?? 'Ocurrió un error');
      } catch (e) {
        mostrarAlerta('Error', 'Ocurrió un error inesperado');
      }
    }
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
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: SideMenu(companyName: widget.companyName),
      appBar: AppBarReportes(titleText: ''),
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
                'Registro de Usuario',
                style: TextStyle(fontFamily: 'Lato', fontSize: 30.0),
              ),
              const SizedBox(
                width: 150.0,
                height: 15.0,
                child: Divider(color: Color.fromARGB(255, 77, 161, 201)),
              ),
              SizedBox(
                height: 20,
              ),
              // Empresa y Rol
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: empresaController,
                        focusNode: empresaFocusNode,
                        decoration: const InputDecoration(
                          hintText: 'Empresa',
                          labelText: 'Empresa',
                          suffixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(usuarioFocusNode);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        focusNode: rolFocusNode,
                        value: selectedRole,
                        items: const [
                          DropdownMenuItem(
                            value: 'usuario',
                            child: Text('Usuario'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (newValue) {
                          setState(() {
                            selectedRole = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Rol',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  controller: nombreController,
                  focusNode: nombreFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    labelText: 'Nombre',
                    suffixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                  ),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(rolFocusNode);
                  },
                ),
              ),
              const SizedBox(height: 18.0),
              // Correo electrónico
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
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
              ),
              const SizedBox(height: 20),
              // Contraseña
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
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
              ),
              const SizedBox(height: 18.0),
              // Nombre

              const SizedBox(height: 18.0),
              ElevatedButton(
                onPressed: registrarUsuario,
                child: const Text('Registrar usuario'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
