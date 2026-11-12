import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../templates/models/document_structure.dart';
import '../models/export_options.dart';
import 'canvas_render_service.dart';

class PdfExportService {
  PdfExportService._();
  static final PdfExportService instance = PdfExportService._();

  /// Generates a valid PDF document for the given pages.
  /// Supports single-page and multi-page documents with preserved aspect ratio.
  Future<Uint8List> generatePdf({
    required List<DocumentPage> pages,
    required ExportConfig config,
    double baseWidth = CanvasRenderService.defaultBaseWidth,
    double baseHeight = CanvasRenderService.defaultBaseHeight,
  }) async {
    if (pages.isEmpty) {
      throw Exception('لا توجد صفحات لتصديرها إلى PDF');
    }

    final pw.Document pdf = pw.Document(
      title: 'ANSHIILY Document',
      author: 'ANSHIILY - أنشئلي',
      creator: 'ANSHIILY Professional Export Engine',
    );

    // Calculate PDF page format in points (1 point = 1/72 inch)
    // For standard 1080x1080, aspect ratio is 1:1. Standard square format:
    final double pagePtWidth = (baseWidth / baseHeight >= 1)
        ? PdfPageFormat.a4.width
        : PdfPageFormat.a4.width * (baseWidth / baseHeight);
    final double pagePtHeight = pagePtWidth * (baseHeight / baseWidth);

    final PdfPageFormat customFormat = PdfPageFormat(
      pagePtWidth,
      pagePtHeight,
      marginAll: 0,
    );

    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];

      // Render page at high fidelity (High or Print 300 DPI)
      final Uint8List pageRasterBytes = await CanvasRenderService.instance
          .renderPageToImageBytes(
            page: page,
            config: config.copyWith(
              format: ExportFormat.png,
              transparentBackground:
                  false, // PDF pages should have solid background
            ),
            baseWidth: baseWidth,
            baseHeight: baseHeight,
          );

      final pw.MemoryImage memoryImage = pw.MemoryImage(pageRasterBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: customFormat,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.Image(memoryImage, fit: pw.BoxFit.fill),
            );
          },
        ),
      );
    }

    return await pdf.save();
  }
}
