import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetVentas {
  static List<Map<String, dynamic>> ventas = [];

  static Future<void> fetchData(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await Dio().get(
        'https://www.nhubex.com/ServGenerales/General/ejecutarStoredGenericoWithFormat/pe?stored_name=REP_VENTAS_POWERBI&attributes=%7B%22DATOS%22:%7B%7D%7D&format=JSON&isFront=true',
      );
      if (response.statusCode == 200) {
        if (Navigator.of(context).canPop()) {
          List<dynamic> registros =
              json.decode(response.data)["RESPUESTA"]["registro"];
          ventas = registros.map<Map<String, dynamic>>((registro) {
            return {
              'Fecha': registro["Fecha"],
              'Descripcion': registro["Descripcion"],
              'IdDiario': registro["IdDiario"],
              'IDHub': registro["IDHub"],
              'IdM3': registro["IdM3"],
              'IdTrx': registro["IdTrx"],
              'NDoc': registro["NDoc"],
              'NOM_Cliente': registro["NOM_Cliente"],
              'Nombre': registro["Nombre"],
              'TMIdProceso': registro["TMIdProceso"],
              'UUID': registro["UUID"],
              'Valor': registro["Valor"],
              'ValorNeto': registro["ValorNeto"],
              'Vendedor': registro["Vendedor"],
              'Vendedor2': registro["Vendedor2"],
            };
          }).toList();
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        print('Error fetching data: $e');
        throw Exception('Failed to load data');
      }
    }
  }
}
