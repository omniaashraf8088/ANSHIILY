import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../auth/models/user_profile.dart';

class HomeHeader extends StatelessWidget {
  final UserProfile? profile;
  final bool isAuthenticated;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationsTap;

  const HomeHeader({
    super.key,
    required this.profile,
    required this.isAuthenticated,
    required this.onProfileTap,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final name =
        profile?.fullName ?? (isAuthenticated ? 'مستخدم أنشئلي' : 'ضيف كريم');
    final credits = profile?.credits ?? 10;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Logo & User greeting
          Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AppColors.champagneGold, AppColors.burgundy],
                    ),
                    border: Border.all(
                      color: AppColors.champagneGold,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.champagneGold.withValues(alpha: 0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(AppAssets.appIcon, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً، $name',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'من فكرة إلى تصميم',
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Credits Badge & Notification Bell & Profile Avatar
          Row(
            children: [
              // Credits Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.champagneGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.champagneGold,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$credits رصيد',
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Notifications Icon
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.champagneGold,
                      size: 24,
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.burgundy,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                tooltip: 'الإشعارات',
                onPressed: onNotificationsTap,
              ),

              // Profile Avatar Button
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceNavy,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0] : 'U',
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
