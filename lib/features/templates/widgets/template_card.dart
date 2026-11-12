import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/template_model.dart';

class TemplateCard extends StatelessWidget {
  final TemplateModel template;
  final VoidCallback onTap;
  final bool isHorizontal;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 175,
          margin: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview image
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      template.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallback(),
                    ),
                    // Gradient overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Badge: Free or Premium
                    Positioned(top: 8, right: 8, child: _buildBadge()),
                    // Pages count
                    if (template.pageCount > 1)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.deepNavy.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.champagneGold.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Text(
                            '${template.pageCount} صفحات',
                            style: GoogleFonts.tajawal(
                              color: AppColors.warmIvory,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.nameAr,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.dimensionsString,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.55),
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceNavy,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    template.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallback(),
                  ),
                  Positioned(top: 10, right: 10, child: _buildBadge()),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(
                            alpha: 0.35,
                          ),
                        ),
                      ),
                      child: Text(
                        '${template.width.toInt()}×${template.height.toInt()}',
                        style: GoogleFonts.tajawal(
                          color: AppColors.champagneGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.nameAr,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          template.nameEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (template.pageCount > 1) ...[
                        const SizedBox(width: 4),
                        Text(
                          '${template.pageCount} صفحات',
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.7,
                            ),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    if (template.isPremium) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.burgundy,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: AppColors.champagneGold, size: 10),
            const SizedBox(width: 4),
            Text(
              'بريميوم',
              style: GoogleFonts.tajawal(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.teal.shade800.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'مجاني',
        style: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.surfaceNavy,
      child: Center(
        child: Icon(
          Icons.design_services_outlined,
          color: AppColors.champagneGold.withValues(alpha: 0.4),
          size: 32,
        ),
      ),
    );
  }
}
