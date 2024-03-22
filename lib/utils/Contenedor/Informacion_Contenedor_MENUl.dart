import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/home_page.dart';
import 'package:flutter_proyect/models/PolyElectric/graph.ventas.dart';
import 'package:flutter_proyect/models/PolyElectric/miau.dart';
import 'package:flutter_proyect/utils/Contenedor/AppBarVentas.dart';

class Informacion extends StatelessWidget {
  const Informacion({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reportes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ButtonTheme(
                    minWidth: 170,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GraphBar()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black,
                        elevation: 5,
                      ),
                      //primer botton
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        //alignment: Alignment.center,
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/grafico.png',
                              width: 30,
                              height: 30,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Ventas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      //terminacion
                    ),
                  ),
                ),

                //segundo botton
                const SizedBox(width: 10), // Espacio entre botones
                Expanded(
                  child: ButtonTheme(
                    minWidth: 170,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomePage1()));
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black,
                        elevation: 5,
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_alarm,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Otro Botón',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10), // Espacio entre filas
            //creacion de sgunda ilera
            Row(
              children: [
                Expanded(
                  child: ButtonTheme(
                    minWidth: 170,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción para el tercer botón
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black,
                        elevation: 5,
                      ),
                      //segunda fila
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Tercer Botón',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Espacio entre botones
                Expanded(
                  child: ButtonTheme(
                    minWidth: 170,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción para el cuarto botón
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black,
                        elevation: 5,
                      ),
                      //segunda fila
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications,
                              color: Colors.black,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Cuarto Botón',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
