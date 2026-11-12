import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class HomeHeroSection extends StatelessWidget {
  final VoidCallback onStartDesign;

  const HomeHeroSection({super.key, required this.onStartDesign});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F2D4E), Color(0xFF141F36), Color(0xFF2E1220)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.champagneGold.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Decorative background patterns
            Positioned(
              top: -30,
              left: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.champagneGold.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.burgundy.withValues(alpha: 0.15),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.champagneGold.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Text(
                          'منصة أنشئلي الذكية ✨',
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.auto_fix_high_rounded,
                        color: AppColors.champagneGold,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Required Title
                  Text(
                    'كل فكرة تستحق تصميمًا مميزًا',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Required Description
                  Text(
                    'حوّل أفكارك إلى تصميمات احترافية بمساعدة الذكاء الاصطناعي.',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.85),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Required Primary Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: onStartDesign,
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                      ),
                      label: Text(
                        'ابدأ تصميمك الآن',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.champagneGold,
                        foregroundColor: AppColors.deepNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
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
}
