import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class PdfGenerator {
  // Método para generar el PDF
  Future<void> generatePdf({
    required String title,
    required String subtitle,
    required List<List<String>> tableData,
    required Uint8List chartImage,
  }) async {
    // Crea un documento PDF
    final pdf = pw.Document();

    // Agrega una página al documento
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Título del documento
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              // Subtítulo del documento
              pw.Text(
                subtitle,
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 20),
              // Captura de la gráfica
              if (chartImage.isNotEmpty)
                pw.Image(
                  pw.MemoryImage(chartImage),
                  height: 200,
                ),
              pw.SizedBox(height: 20),
              // Tabla de datos
              pw.Table.fromTextArray(
                context: context,
                data: tableData,
              ),
            ],
          );
        },
      ),
    );

    // Define el directorio donde se guardará el PDF
    final outputDir = await getApplicationDocumentsDirectory();
    final outputFile = File('${outputDir.path}/documento.pdf');

    // Guarda el PDF en el archivo
    try {
      await outputFile.writeAsBytes(await pdf.save());
      print('PDF generado y guardado en: ${outputFile.path}');
    } catch (e) {
      print('Error al guardar el PDF: $e');
    }
  }
}
