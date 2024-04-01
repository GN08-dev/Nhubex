import 'package:flutter/material.dart';

class InicioInfo extends StatefulWidget {
  const InicioInfo({Key? key}) : super(key: key);

  @override
  State<InicioInfo> createState() => _InicioInfoState();
}

class _InicioInfoState extends State<InicioInfo> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sin informacion por el momento ',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
