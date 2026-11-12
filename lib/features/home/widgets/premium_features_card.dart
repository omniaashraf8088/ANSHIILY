import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';

class PremiumFeaturesCard extends StatelessWidget {
  const PremiumFeaturesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF28101C), Color(0xFF131D38), Color(0xFF0B132B)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.champagneGold.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.champagneGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.champagneGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أنشئلي بريميوم (ANSHIILY Pro)',
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'ارتقِ بإبداعك مع مزايا استثنائية',
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.burgundy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'VIP',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildFeatureBullet(
              icon: Icons.auto_awesome_rounded,
              title: 'توليد ذكي فائق الدقة وسرعة معالجة أولوية',
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              icon: Icons.picture_as_pdf_rounded,
              title:
                  'تصدير بدون علامة مائية بصيغ فيكتور SVG و PDF جاهزة للطباعة',
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              icon: Icons.star_rounded,
              title:
                  'وصول غير محدود لكافة قوالب المصممين الحصرية والمكتبة الملكية',
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              icon: Icons.cloud_done_rounded,
              title: 'سعة تخزينية سحابية غير محدودة على Supabase لمشاريعك',
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.subscription),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.champagneGold,
                  foregroundColor: AppColors.deepNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'اكتشف مميزات بريميوم',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet({required IconData icon, required String title}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.champagneGold, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(
              color: AppColors.warmIvory.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
