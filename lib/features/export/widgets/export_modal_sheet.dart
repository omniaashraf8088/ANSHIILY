import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../templates/models/document_structure.dart';
import '../models/export_options.dart';
import '../services/canvas_render_service.dart';
import '../services/export_service.dart';

class ExportModalSheet extends StatefulWidget {
  final TemplateDocument document;
  final String projectTitle;
  final String? projectId;
  final int currentPageIndex;

  const ExportModalSheet({
    super.key,
    required this.document,
    required this.projectTitle,
    this.projectId,
    required this.currentPageIndex,
  });

  static Future<void> show(
    BuildContext context, {
    required TemplateDocument document,
    required String projectTitle,
    String? projectId,
    required int currentPageIndex,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExportModalSheet(
        document: document,
        projectTitle: projectTitle,
        projectId: projectId,
        currentPageIndex: currentPageIndex,
      ),
    );
  }

  @override
  State<ExportModalSheet> createState() => _ExportModalSheetState();
}

class _ExportModalSheetState extends State<ExportModalSheet> {
  ExportFormat _selectedFormat = ExportFormat.png;
  ExportQuality _selectedQuality = ExportQuality.high;
  ExportPageScope _selectedScope = ExportPageScope.currentPage;
  bool _transparentBackground = false;

  bool _isExporting = false;
  String _exportStage = '';
  ExportResult? _lastResult;

  int get _calculatedWidth =>
      (CanvasRenderService.defaultBaseWidth * _selectedQuality.scaleFactor)
          .round();
  int get _calculatedHeight =>
      (CanvasRenderService.defaultBaseHeight * _selectedQuality.scaleFactor)
          .round();

  Future<void> _startExport({bool shareImmediately = false}) async {
    setState(() {
      _isExporting = true;
      _exportStage = 'جاري معالجة طبقات المستند...';
      _lastResult = null;
    });

    final config = ExportConfig(
      format: _selectedFormat,
      quality: _selectedQuality,
      scope: _selectedScope,
      selectedPageIndex: widget.currentPageIndex,
      transparentBackground: _transparentBackground,
    );

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _exportStage = 'جاري الترميز وحفظ الملف بدقة فائقة...';
    });

    final result = await ExportService.instance.exportDocument(
      document: widget.document,
      projectTitle: widget.projectTitle,
      config: config,
      projectId: widget.projectId,
    );

    if (!mounted) return;

    setState(() {
      _isExporting = false;
      _lastResult = result;
    });

    if (result.success && shareImmediately && result.filePath != null) {
      await ExportService.instance.shareExportedFile(
        filePath: result.filePath!,
        projectTitle: widget.projectTitle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceNavy,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.champagneGold.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.warmIvory,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'تصدير التصميم (Export)',
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Icon(
                  Icons.file_download_outlined,
                  color: AppColors.champagneGold,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_lastResult != null && _lastResult!.success)
              _buildSuccessBanner()
            else if (_lastResult != null && !_lastResult!.success)
              _buildErrorBanner(_lastResult!.errorMessage ?? 'فشل التصدير')
            else if (_isExporting)
              _buildExportingState()
            else ...[
              // 1. Format Selection
              _buildSectionTitle('1. صيغة الملف (File Format)'),
              const SizedBox(height: 8),
              _buildFormatSelector(),
              const SizedBox(height: 18),

              // 2. Quality Selection
              _buildSectionTitle('2. دقة وجودة التصدير (Resolution & Quality)'),
              const SizedBox(height: 8),
              _buildQualitySelector(),
              const SizedBox(height: 18),

              // 3. Pages Scope
              _buildSectionTitle('3. نطاق الصفحات (Pages Scope)'),
              const SizedBox(height: 8),
              _buildScopeSelector(),
              const SizedBox(height: 18),

              // 4. Options
              if (_selectedFormat == ExportFormat.png) ...[
                _buildSectionTitle('4. خيارات إضافية'),
                const SizedBox(height: 8),
                _buildTransparencyToggle(),
                const SizedBox(height: 18),
              ],

              // 5. Specs Preview
              _buildSpecsSummaryCard(),
              const SizedBox(height: 20),

              // 6. Action Buttons
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textDirection: TextDirection.rtl,
      style: GoogleFonts.tajawal(
        color: AppColors.warmIvory,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: [
        _buildFormatChip(
          ExportFormat.png,
          'PNG',
          'شفافية ونقاء',
          Icons.image_outlined,
        ),
        const SizedBox(width: 8),
        _buildFormatChip(
          ExportFormat.jpg,
          'JPG',
          'مضغوط وخفيف',
          Icons.collections_outlined,
        ),
        const SizedBox(width: 8),
        _buildFormatChip(
          ExportFormat.pdf,
          'PDF',
          'جاهز للطباعة',
          Icons.picture_as_pdf_outlined,
        ),
      ],
    );
  }

  Widget _buildFormatChip(
    ExportFormat format,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final bool isSelected = _selectedFormat == format;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedFormat = format),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.champagneGold.withValues(alpha: 0.18)
                : AppColors.deepNavy,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.champagneGold
                  : AppColors.champagneGold.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.champagneGold
                    : AppColors.warmIvory.withValues(alpha: 0.6),
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.tajawal(
                  color: isSelected
                      ? AppColors.champagneGold
                      : AppColors.warmIvory,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.tajawal(
                  color: AppColors.warmIvory.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualitySelector() {
    return Column(
      children: ExportQuality.values.map((q) {
        final bool isSelected = _selectedQuality == q;
        final bool isPro = q == ExportQuality.print300Dpi;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedQuality = q),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.champagneGold.withValues(alpha: 0.15)
                    : AppColors.deepNavy,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.champagneGold
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.champagneGold
                            : AppColors.warmIvory.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.champagneGold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              q.labelAr,
                              style: GoogleFonts.tajawal(
                                color: isSelected
                                    ? AppColors.champagneGold
                                    : AppColors.warmIvory,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            if (isPro) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.burgundy,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '300 DPI ★',
                                  style: GoogleFonts.tajawal(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          q.descriptionAr,
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.65),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScopeSelector() {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            label: Text(
              'الصفحة الحالية (${widget.currentPageIndex + 1})',
              style: GoogleFonts.tajawal(
                color: _selectedScope == ExportPageScope.currentPage
                    ? AppColors.deepNavy
                    : AppColors.warmIvory,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            selected: _selectedScope == ExportPageScope.currentPage,
            selectedColor: AppColors.champagneGold,
            backgroundColor: AppColors.deepNavy,
            onSelected: (_) {
              setState(() => _selectedScope = ExportPageScope.currentPage);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ChoiceChip(
            label: Text(
              'جميع الصفحات (${widget.document.pages.length})',
              style: GoogleFonts.tajawal(
                color: _selectedScope == ExportPageScope.allPages
                    ? AppColors.deepNavy
                    : AppColors.warmIvory,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            selected: _selectedScope == ExportPageScope.allPages,
            selectedColor: AppColors.champagneGold,
            backgroundColor: AppColors.deepNavy,
            onSelected: (_) {
              setState(() => _selectedScope = ExportPageScope.allPages);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransparencyToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.opacity_rounded,
                color: AppColors.champagneGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'خلفية شفافة (Transparent PNG)',
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'إزالة لون الخلفية للشعارات والعناصر المعزولة',
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _transparentBackground,
            activeThumbColor: AppColors.champagneGold,
            onChanged: (val) => setState(() => _transparentBackground = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepNavy.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSpecItem(
            'الأبعاد',
            '$_calculatedWidth × $_calculatedHeight px',
          ),
          _buildSpecItem('الكثافة', '${_selectedQuality.dpi} DPI'),
          _buildSpecItem(
            'الصفحات',
            _selectedScope == ExportPageScope.allPages
                ? '${widget.document.pages.length}'
                : '1',
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _startExport(shareImmediately: false),
            icon: const Icon(Icons.file_download_rounded, size: 20),
            label: Text(
              'تصدير وحفظ',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.deepNavy,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () => _startExport(shareImmediately: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.burgundy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Icon(Icons.share_rounded, size: 20),
        ),
      ],
    );
  }

  Widget _buildExportingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.champagneGold,
            strokeWidth: 3,
          ),
          const SizedBox(height: 18),
          Text(
            _exportStage,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(
              color: AppColors.champagneGold,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جاري تجهيز الملف بأعلى جودة ممكنة...',
            style: GoogleFonts.tajawal(
              color: AppColors.warmIvory.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    final res = _lastResult!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.greenAccent, width: 1.2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.greenAccent,
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            'تم التصدير بنجاح! 🎉',
            style: GoogleFonts.tajawal(
              color: AppColors.champagneGold,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'الحجم: ${res.formattedFileSize} | الصفحات: ${res.pageCount} | الصيغة: ${res.format.extension.toUpperCase()}',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(
              color: AppColors.warmIvory.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (res.filePath != null) {
                      ExportService.instance.shareExportedFile(
                        filePath: res.filePath!,
                        projectTitle: widget.projectTitle,
                      );
                    }
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    'مشاركة الملف',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: AppColors.deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warmIvory,
                  side: const BorderSide(color: AppColors.champagneGold),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'تم',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent, width: 1.2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            'فشل التصدير',
            style: GoogleFonts.tajawal(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              color: AppColors.warmIvory.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => setState(() => _lastResult = null),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.deepNavy,
            ),
            child: Text(
              'إعادة المحاولة',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
