import 'dart:typed_data';

enum ExportFormat {
  png,
  jpg,
  pdf;

  String get labelAr {
    switch (this) {
      case ExportFormat.png:
        return 'PNG (صورة عالية الدقة)';
      case ExportFormat.jpg:
        return 'JPG (صورة مضغوطة)';
      case ExportFormat.pdf:
        return 'PDF (مستند للطباعة والمشاركة)';
    }
  }

  String get extension {
    switch (this) {
      case ExportFormat.png:
        return 'png';
      case ExportFormat.jpg:
        return 'jpg';
      case ExportFormat.pdf:
        return 'pdf';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.png:
        return 'image/png';
      case ExportFormat.jpg:
        return 'image/jpeg';
      case ExportFormat.pdf:
        return 'application/pdf';
    }
  }
}

enum ExportQuality {
  standard(
    1.0,
    72,
    'عادية (Standard - 1x)',
    'مناسبة للشاشات والمراسلات السريعة',
  ),
  high(
    2.0,
    150,
    'عالية (High Quality - 2x)',
    'مثالية لمنصات التواصل الاجتماعي بجودة نقية',
  ),
  print300Dpi(
    4.1667,
    300,
    'جودة طباعة (Print Quality - 300 DPI)',
    'دقة فائقة مخصصة للمطابع والمطبوعات الورقية',
  );

  final double scaleFactor;
  final int dpi;
  final String labelAr;
  final String descriptionAr;

  const ExportQuality(
    this.scaleFactor,
    this.dpi,
    this.labelAr,
    this.descriptionAr,
  );
}

enum ExportPageScope {
  currentPage('الصفحة الحالية فقط'),
  allPages('جميع صفحات المشروع');

  final String labelAr;
  const ExportPageScope(this.labelAr);
}

class ExportConfig {
  final ExportFormat format;
  final ExportQuality quality;
  final ExportPageScope scope;
  final int selectedPageIndex;
  final bool transparentBackground;
  final String? fallbackBackgroundColor;
  final int jpgQuality; // 1 - 100

  const ExportConfig({
    this.format = ExportFormat.png,
    this.quality = ExportQuality.high,
    this.scope = ExportPageScope.currentPage,
    this.selectedPageIndex = 0,
    this.transparentBackground = false,
    this.fallbackBackgroundColor = '#0B132B',
    this.jpgQuality = 92,
  });

  ExportConfig copyWith({
    ExportFormat? format,
    ExportQuality? quality,
    ExportPageScope? scope,
    int? selectedPageIndex,
    bool? transparentBackground,
    String? fallbackBackgroundColor,
    int? jpgQuality,
  }) {
    return ExportConfig(
      format: format ?? this.format,
      quality: quality ?? this.quality,
      scope: scope ?? this.scope,
      selectedPageIndex: selectedPageIndex ?? this.selectedPageIndex,
      transparentBackground:
          transparentBackground ?? this.transparentBackground,
      fallbackBackgroundColor:
          fallbackBackgroundColor ?? this.fallbackBackgroundColor,
      jpgQuality: jpgQuality ?? this.jpgQuality,
    );
  }
}

class ExportResult {
  final bool success;
  final String? filePath;
  final ExportFormat format;
  final Uint8List? bytes;
  final int fileSizeBytes;
  final int pageCount;
  final int width;
  final int height;
  final String? errorMessage;

  const ExportResult({
    required this.success,
    this.filePath,
    required this.format,
    this.bytes,
    this.fileSizeBytes = 0,
    this.pageCount = 1,
    this.width = 0,
    this.height = 0,
    this.errorMessage,
  });

  factory ExportResult.failure(ExportFormat format, String error) {
    return ExportResult(success: false, format: format, errorMessage: error);
  }

  String get formattedFileSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
