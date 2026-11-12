import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../projects/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final bool isCompact;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isCompact = false,
  });

  IconData _getIconData(String name) {
    switch (name) {
      case 'share':
        return Icons.share_rounded;
      case 'campaign':
        return Icons.campaign_rounded;
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'feed':
        return Icons.feed_rounded;
      case 'description':
        return Icons.description_rounded;
      case 'calendar_today':
        return Icons.calendar_today_rounded;
      case 'slideshow':
        return Icons.slideshow_rounded;
      case 'mail':
        return Icons.mail_outline_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'person':
        return Icons.person_outline_rounded;
      case 'brush':
      default:
        return Icons.brush_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 130,
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.25),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (category.coverImage != null)
                      Image.network(
                        category.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildFallback(),
                      )
                    else
                      _buildFallback(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.surfaceNavy.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        child: Icon(
                          _getIconData(category.iconName),
                          color: AppColors.champagneGold,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  category.nameAr,
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
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
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.surfaceNavy,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (category.coverImage != null)
              Positioned.fill(
                child: Image.network(
                  category.coverImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallback(),
                ),
              )
            else
              Positioned.fill(child: _buildFallback()),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.deepNavy.withValues(alpha: 0.95),
                      AppColors.deepNavy.withValues(alpha: 0.8),
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.champagneGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.champagneGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      _getIconData(category.iconName),
                      color: AppColors.champagneGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.nameAr,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.descriptionAr ?? category.nameEn,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.75),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.champagneGold,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.surfaceNavy,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.champagneGold.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
