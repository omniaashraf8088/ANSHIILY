import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/supabase_service.dart';
import '../../templates/models/document_structure.dart';
import '../models/export_options.dart';
import 'canvas_render_service.dart';
import 'pdf_export_service.dart';

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  /// Executes the export operation based on the provided [config] and [document].
  Future<ExportResult> exportDocument({
    required TemplateDocument document,
    required String projectTitle,
    required ExportConfig config,
    String? projectId,
  }) async {
    // 1. Validation
    if (document.pages.isEmpty) {
      return ExportResult.failure(
        config.format,
        'المستند فارغ، لا توجد صفحات للتصدير',
      );
    }

    try {
      // 2. Determine target pages
      final List<DocumentPage> targetPages;
      if (config.scope == ExportPageScope.allPages) {
        targetPages = List<DocumentPage>.from(document.pages);
      } else {
        final int index = config.selectedPageIndex.clamp(
          0,
          document.pages.length - 1,
        );
        targetPages = [document.pages[index]];
      }

      Uint8List fileBytes;
      int outputWidth =
          (CanvasRenderService.defaultBaseWidth * config.quality.scaleFactor)
              .round();
      int outputHeight =
          (CanvasRenderService.defaultBaseHeight * config.quality.scaleFactor)
              .round();

      if (config.format == ExportFormat.pdf) {
        // PDF Export (Single or Multi-Page)
        fileBytes = await PdfExportService.instance.generatePdf(
          pages: targetPages,
          config: config,
        );
      } else {
        // Raster Image Export (PNG or JPG)
        // If single page: render that page directly
        // If all pages chosen for PNG/JPG, render the first selected page or current page
        final pageToRender = targetPages.first;
        fileBytes = await CanvasRenderService.instance.renderPageToImageBytes(
          page: pageToRender,
          config: config,
        );
      }

      // 3. Save File to Device
      final String sanitizedTitle = _sanitizeFileName(
        projectTitle.isNotEmpty ? projectTitle : 'تصميم_أنشئلي',
      );
      final String timestamp = DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(6);
      final String fileName =
          'ANSHIILY_${sanitizedTitle}_$timestamp.${config.format.extension}';

      final Directory tempDir = await getTemporaryDirectory();
      final File savedFile = File('${tempDir.path}/$fileName');
      await savedFile.writeAsBytes(fileBytes, flush: true);

      // 4. Log export job in Supabase (if user is authenticated)
      _logExportJobInSupabase(
        projectId: projectId,
        format: config.format.extension,
      );

      return ExportResult(
        success: true,
        filePath: savedFile.path,
        format: config.format,
        bytes: fileBytes,
        fileSizeBytes: fileBytes.lengthInBytes,
        pageCount: targetPages.length,
        width: outputWidth,
        height: outputHeight,
      );
    } catch (e) {
      return ExportResult.failure(config.format, 'حدث خطأ أثناء التصدير: $e');
    }
  }

  /// Shares an exported file via native system sheet.
  Future<void> shareExportedFile({
    required String filePath,
    required String projectTitle,
  }) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('الملف المراد مشاركته غير موجود على الجهاز');
    }

    final xFile = XFile(filePath, name: file.uri.pathSegments.last);

    await Share.shareXFiles([
      xFile,
    ], text: 'تصميم تم إنشاؤه عبر منصة أنشئلي (ANSHIILY) - $projectTitle');
  }

  void _logExportJobInSupabase({
    String? projectId,
    required String format,
  }) async {
    try {
      final user = SupabaseService.instance.currentUser;
      if (user == null) return;

      await SupabaseService.instance.client?.from('export_jobs').insert({
        'user_id': user.id,
        if (projectId != null && projectId != 'new') 'project_id': projectId,
        'export_format': format,
        'status': 'completed',
      });
    } catch (_) {
      // Non-blocking background log
    }
  }

  String _sanitizeFileName(String name) {
    return name
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(' ', '_')
        .trim();
  }
}
