import 'package:flutter/material.dart';
import 'package:flutter_proyect/src/Menu_Principal.dart';

class MyAppForm extends StatefulWidget {
  const MyAppForm({super.key});

  @override
  State<MyAppForm> createState() => _MyAppFormState();
}

class _MyAppFormState extends State<MyAppForm> {
  final empresaController = TextEditingController();
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    empresaController.dispose();
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  late FocusNode usuarioFocusNode;
  late FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    usuarioFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
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
                child: Image.asset('assets/images/nhubex.png'),
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
              //empresa
              TextFormField(
                controller: empresaController,
                enableInteractiveSelection: false,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: "Dijita las siglas",
                  labelText: "Empresa",
                  suffixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(usuarioFocusNode);
                },
              ),
              const SizedBox(height: 18.0),
              //usuario
              TextFormField(
                controller: usuarioController,
                focusNode: usuarioFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Usuario',
                  labelText: 'Usuario',
                  suffixIcon: Icon(Icons.account_circle),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  ),
                ),
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(passwordFocusNode);
                },
              ),
              //pasword
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
                onPressed: () {
                  String empresa = empresaController.text;
                  String usuario = usuarioController.text;
                  String password = passwordController.text;

                  if (empresa.isEmpty || usuario.isEmpty || password.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('favor de llenar el formulario'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok'))
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainMenu()));
                  }
                },
                child: const Text('Iniciar sesión'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
