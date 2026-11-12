import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../templates/models/document_structure.dart';
import '../../templates/utils/editor_font_helper.dart';
import '../models/export_options.dart';

class CanvasRenderService {
  CanvasRenderService._();
  static final CanvasRenderService instance = CanvasRenderService._();

  static const double defaultBaseWidth = 1080.0;
  static const double defaultBaseHeight = 1080.0;

  /// Renders a single [DocumentPage] to raster image bytes (PNG or JPG).
  Future<Uint8List> renderPageToImageBytes({
    required DocumentPage page,
    required ExportConfig config,
    double baseWidth = defaultBaseWidth,
    double baseHeight = defaultBaseHeight,
  }) async {
    final double scale = config.quality.scaleFactor;
    final int targetWidth = (baseWidth * scale).round();
    final int targetHeight = (baseHeight * scale).round();

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
    );

    // 1. Draw Background
    _drawBackground(
      canvas: canvas,
      page: page,
      config: config,
      width: targetWidth.toDouble(),
      height: targetHeight.toDouble(),
    );

    // 2. Draw Elements in order
    for (final element in page.elements) {
      _drawElement(canvas: canvas, element: element, scale: scale);
    }

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(targetWidth, targetHeight);

    if (config.format == ExportFormat.png) {
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Exception('فشل تحويل الصورة إلى تنسيق PNG');
      }
      return byteData.buffer.asUint8List();
    } else {
      // JPG Encoding
      final ByteData? rawRgba = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (rawRgba == null) {
        throw Exception('فشل قراءة بيانات الصورة الخام لترميز JPG');
      }
      final img.Image decodedImg = img.Image.fromBytes(
        width: targetWidth,
        height: targetHeight,
        bytes: rawRgba.buffer,
        numChannels: 4,
      );
      final List<int> jpgBytes = img.encodeJpg(
        decodedImg,
        quality: config.jpgQuality,
      );
      return Uint8List.fromList(jpgBytes);
    }
  }

  void _drawBackground({
    required Canvas canvas,
    required DocumentPage page,
    required ExportConfig config,
    required double width,
    required double height,
  }) {
    final bool isTransparent =
        config.transparentBackground && config.format == ExportFormat.png;
    if (isTransparent) {
      return; // Leave transparent canvas
    }

    final Color bgColor = _parseColor(
      page.background?.color ?? config.fallbackBackgroundColor ?? '#0B132B',
      fallback: const Color(0xFF0B132B),
    );

    final Paint bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Decorative gradient overlay if dark theme background
    if (bgColor.computeLuminance() < 0.2) {
      final Paint gradPaint = Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(width, height),
          [
            const Color(0xFFD4AF37).withValues(alpha: 0.08),
            const Color(0xFF7A0E2C).withValues(alpha: 0.12),
            Colors.transparent,
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), gradPaint);
    }
  }

  void _drawElement({
    required Canvas canvas,
    required DocumentElement element,
    required double scale,
  }) {
    final double x = element.x * scale;
    final double y = element.y * scale;
    final double w = element.width * scale;
    final double h = element.height * scale;

    canvas.save();

    // Rotation transform around element center
    if (element.rotation != 0) {
      final double centerX = x + w / 2;
      final double centerY = y + h / 2;
      canvas.translate(centerX, centerY);
      canvas.rotate(element.rotation * pi / 180);
      canvas.translate(-centerX, -centerY);
    }

    switch (element.type) {
      case 'text':
        _drawTextElement(canvas, element, x, y, w, h, scale);
        break;
      case 'shape':
        _drawShapeElement(canvas, element, x, y, w, h);
        break;
      case 'image':
      case 'decorative':
        _drawImageElement(canvas, element, x, y, w, h);
        break;
      default:
        _drawGenericElement(canvas, element, x, y, w, h);
    }

    canvas.restore();
  }

  void _drawTextElement(
    Canvas canvas,
    DocumentElement element,
    double x,
    double y,
    double w,
    double h,
    double scale,
  ) {
    final styleMap = element.style;
    final String fontFamily = styleMap['fontFamily'] as String? ?? 'Cairo';
    final double fontSize =
        ((styleMap['fontSize'] as num?)?.toDouble() ?? 24.0) * scale;
    final Color textColor = _parseColor(
      styleMap['color'] as String?,
      fallback: const Color(0xFFD4AF37),
    );
    final bool isBold = styleMap['fontWeight'] == 'bold';
    final bool isItalic = styleMap['fontStyle'] == 'italic';
    final TextAlign textAlign = _parseTextAlign(
      styleMap['textAlign'] as String?,
    );

    final TextStyle textStyle = EditorFontHelper.getTextStyle(
      fontFamily,
      fontSize: fontSize,
      color: textColor.withValues(alpha: element.opacity),
      fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );

    final TextDirection textDirection = _detectTextDirection(element.content);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: element.content, style: textStyle),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: 10,
    );

    textPainter.layout(maxWidth: w);
    textPainter.paint(canvas, Offset(x, y));
  }

  void _drawShapeElement(
    Canvas canvas,
    DocumentElement element,
    double x,
    double y,
    double w,
    double h,
  ) {
    final styleMap = element.style;
    final Color fillColor = _parseColor(
      styleMap['backgroundColor'] as String? ?? styleMap['color'] as String?,
      fallback: const Color(0xFFD4AF37),
    ).withValues(alpha: element.opacity);

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final double borderRadius =
        ((styleMap['borderRadius'] as num?)?.toDouble() ?? 8.0);
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, fillPaint);

    // Border if specified
    if (styleMap['borderColor'] != null) {
      final Color borderColor = _parseColor(
        styleMap['borderColor'] as String?,
        fallback: Colors.transparent,
      );
      final double borderWidth =
          (styleMap['borderWidth'] as num?)?.toDouble() ?? 1.0;
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  void _drawImageElement(
    Canvas canvas,
    DocumentElement element,
    double x,
    double y,
    double w,
    double h,
  ) {
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, w, h),
      const Radius.circular(12),
    );

    // Decorative placeholder card for images
    final Paint fillPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(x, y), Offset(x + w, y + h), [
        const Color(0xFF131D38).withValues(alpha: element.opacity),
        const Color(0xFF28101C).withValues(alpha: element.opacity),
      ]);
    canvas.drawRRect(rrect, fillPaint);

    final Paint borderPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.4 * element.opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawGenericElement(
    Canvas canvas,
    DocumentElement element,
    double x,
    double y,
    double w,
    double h,
  ) {
    final Paint paint = Paint()
      ..color = const Color(
        0xFFD4AF37,
      ).withValues(alpha: 0.2 * element.opacity);
    canvas.drawRect(Rect.fromLTWH(x, y, w, h), paint);
  }

  Color _parseColor(String? hexString, {required Color fallback}) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      String clean = hexString.replaceAll('#', '').trim();
      if (clean.length == 6) clean = 'FF$clean';
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return fallback;
  }

  TextAlign _parseTextAlign(String? alignStr) {
    switch (alignStr) {
      case 'center':
        return TextAlign.center;
      case 'left':
        return TextAlign.left;
      case 'right':
      default:
        return TextAlign.right;
    }
  }

  TextDirection _detectTextDirection(String text) {
    // Check if contains Arabic characters (\u0600 - \u06FF)
    final bool hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
    return hasArabic ? TextDirection.rtl : TextDirection.ltr;
  }
}
