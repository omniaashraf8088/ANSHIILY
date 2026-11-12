import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../models/template_model.dart';
import '../services/template_service.dart';

class TemplatePreviewScreen extends StatefulWidget {
  final String templateId;

  const TemplatePreviewScreen({super.key, required this.templateId});

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  TemplateModel? _template;
  bool _isLoading = true;
  bool _isCreatingProject = false;

  @override
  void initState() {
    super.initState();
    _loadTemplate();
  }

  Future<void> _loadTemplate() async {
    setState(() => _isLoading = true);
    final tpl = await TemplateService.instance.getTemplateById(
      widget.templateId,
    );
    if (!mounted) return;
    setState(() {
      _template = tpl;
      _isLoading = false;
    });
  }

  Future<void> _handleUseTemplate() async {
    if (_template == null) return;
    setState(() => _isCreatingProject = true);

    try {
      final project = await TemplateService.instance.createProjectFromTemplate(
        _template!,
      );

      if (!mounted) return;
      setState(() => _isCreatingProject = false);

      if (project != null) {
        // Navigate to the connected project editor/preparation workspace!
        context.push(
          AppRoutes.projectEditor,
          extra: {'project': project, 'template': _template},
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingProject = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء إعداد المشروع: $e',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
    }
  }

  void _showFullscreenPreview() {
    if (_template == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.5,
                child: Image.network(
                  _template!.previewUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.deepNavy,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.champagneGold),
        ),
      );
    }

    if (_template == null) {
      return Scaffold(
        backgroundColor: AppColors.deepNavy,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.champagneGold,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'لم يتم العثور على القالب المطلوب',
            style: GoogleFonts.tajawal(color: AppColors.warmIvory),
          ),
        ),
      );
    }

    final tpl = _template!;
    final totalElements = tpl.documentData.totalElements;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.deepNavy,
              AppColors.deepNavyMid,
              Color(0xFF0D1830),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.champagneGold,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      'معاينة القالب',
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen_rounded,
                        color: AppColors.champagneGold,
                        size: 26,
                      ),
                      tooltip: 'معاينة بالحجم الكامل',
                      onPressed: _showFullscreenPreview,
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Large Preview Image with badges
                      GestureDetector(
                        onTap: _showFullscreenPreview,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 380),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceNavy,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.champagneGold.withValues(
                                alpha: 0.35,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                tpl.previewUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 260,
                                      color: AppColors.surfaceNavy,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: AppColors.champagneGold,
                                          size: 48,
                                        ),
                                      ),
                                    ),
                              ),
                              // Tier Badge
                              Positioned(
                                top: 14,
                                right: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tpl.isPremium
                                        ? AppColors.burgundy
                                        : Colors.teal.shade800,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (tpl.isPremium) ...[
                                        const Icon(
                                          Icons.star,
                                          color: AppColors.champagneGold,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        tpl.isPremium
                                            ? 'قالب بريميوم'
                                            : 'قالب مجاني',
                                        style: GoogleFonts.tajawal(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tap to zoom hint
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.deepNavy.withValues(
                                      alpha: 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.champagneGold.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.zoom_in_rounded,
                                        size: 14,
                                        color: AppColors.champagneGold,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'انقر للتكبير',
                                        style: GoogleFonts.tajawal(
                                          color: AppColors.warmIvory,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title & Subtitle
                      Text(
                        tpl.nameAr,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.tajawal(
                          color: AppColors.champagneGold,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tpl.nameEn,
                        style: GoogleFonts.cormorantGaramond(
                          color: AppColors.warmIvory.withValues(alpha: 0.7),
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.8,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Description
                      Text(
                        tpl.descriptionAr,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory.withValues(alpha: 0.85),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Specifications Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceNavy,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildSpecRow(
                              icon: Icons.aspect_ratio_rounded,
                              label: 'الأبعاد الدقيقة',
                              value: tpl.dimensionsString,
                            ),
                            const Divider(color: Color(0x22D4AF37), height: 18),
                            _buildSpecRow(
                              icon: Icons.layers_rounded,
                              label: 'عدد الصفحات',
                              value: '${tpl.pageCount} صفحة',
                            ),
                            const Divider(color: Color(0x22D4AF37), height: 18),
                            _buildSpecRow(
                              icon: Icons.category_rounded,
                              label: 'التصنيف',
                              value: tpl.categorySlug,
                            ),
                            const Divider(color: Color(0x22D4AF37), height: 18),
                            _buildSpecRow(
                              icon: Icons.auto_awesome_motion_rounded,
                              label: 'عناصر قابلة للتعديل',
                              value: '$totalElements عنصر هيكلي',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),

              // Bottom Actions Bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceNavy,
                  border: const Border(
                    top: BorderSide(color: Color(0x33D4AF37), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Action 2: معاينة التصميم
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _showFullscreenPreview,
                          icon: const Icon(
                            Icons.remove_red_eye_rounded,
                            size: 16,
                          ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'معاينة التصميم',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.champagneGold,
                            side: const BorderSide(
                              color: AppColors.champagneGold,
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Action 1: استخدم هذا القالب
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isCreatingProject
                              ? null
                              : _handleUseTemplate,
                          icon: _isCreatingProject
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.deepNavy,
                                  ),
                                )
                              : const Icon(Icons.brush_rounded, size: 18),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'استخدم هذا القالب',
                              style: GoogleFonts.tajawal(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.champagneGold,
                            foregroundColor: AppColors.deepNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
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
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.champagneGold, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
