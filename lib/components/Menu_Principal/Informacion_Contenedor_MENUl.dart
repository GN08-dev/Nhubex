import 'package:flutter/material.dart';
import 'package:flutter_proyect/components/Paginas/home_page.dart';
import 'package:flutter_proyect/models/Ventas/Mes.dart';
import 'package:flutter_proyect/models/Ventas/Semana.dart';
import 'package:flutter_proyect/models/Ventas/Today.dart';

class ReportesDelMesActual extends StatelessWidget {
  final String companyName;

  const ReportesDelMesActual({Key? key, required this.companyName});

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
                            builder: (context) => VentaXDia(
                              companyName: companyName,
                            ),
                          ),
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
                              'Día',
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
                            builder: (context) =>
                                VentasXSemanaPrueba(companyName: companyName),
                          ),
                        );
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
                              'Semana',
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MesVentas(companyName: companyName),
                          ),
                        );
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
                              'Mes',
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HomePage(companyName: companyName),
                            ));
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
                              'homepage',
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
