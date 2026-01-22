import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';

class PrintingService {
  static Future<void> printDesign({
    required String title,
    required String? imagePath,
    required String templateName,
  }) async {
    final pdf = pw.Document();

    pw.MemoryImage? image;
    if (imagePath != null && File(imagePath).existsSync()) {
      try {
        final bytes = await File(imagePath).readAsBytes();
        image = pw.MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error loading image for print: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('ThunderCut Design', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Model: $templateName'),
                pw.SizedBox(height: 40),
                pw.Container(
                  width: 300,
                  height: 500,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                  ),
                  child: pw.Center(
                    child: image != null 
                      ? pw.Image(image, fit: pw.BoxFit.contain)
                      : pw.Text('No design image uploaded\n(Template Outline Only)', textAlign: pw.TextAlign.center),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ThunderCut_$title',
    );
  }
}
