import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routing/app_router.dart';
import '../auth/services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: Icons.auto_fix_high_rounded,
      title: AppStrings.onboarding1Title,
      description: AppStrings.onboarding1Desc,
    ),
    _OnboardingData(
      icon: Icons.psychology_rounded,
      title: AppStrings.onboarding2Title,
      description: AppStrings.onboarding2Desc,
    ),
    _OnboardingData(
      icon: Icons.brush_rounded,
      title: AppStrings.onboarding3Title,
      description: AppStrings.onboarding3Desc,
    ),
  ];

  void _finishOnboarding() {
    final nextRoute = AuthService.instance.isAuthenticated
        ? AppRoutes.home
        : AppRoutes.login;
    context.go(nextRoute);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
              // Skip button
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'تخطي',
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPage(
                      data: _pages[index],
                      screenSize: size,
                    );
                  },
                ),
              ),

              // Bottom controls
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 36),
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: ExpandingDotsEffect(
                        activeDotColor: AppColors.champagneGold,
                        dotColor: AppColors.champagneGold.withValues(
                          alpha: 0.25,
                        ),
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3,
                        spacing: 6,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.champagneGold,
                          foregroundColor: AppColors.deepNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          shadowColor: AppColors.champagneGold.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? AppStrings.getStarted
                              : AppStrings.next,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.tajawal(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
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
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Size screenSize;

  const _OnboardingPage({required this.data, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with golden glow container
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [
                      Color(0x33D4AF37),
                      Color(0x11D4AF37),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  data.icon,
                  color: AppColors.champagneGold,
                  size: 64,
                ),
              ),

              const SizedBox(height: 36),

              // Golden separator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 1,
                    color: AppColors.champagneGold.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star,
                    color: AppColors.champagneGold,
                    size: 8,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 30,
                    height: 1,
                    color: AppColors.champagneGold.withValues(alpha: 0.4),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Arabic Title
              Text(
                data.title,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  color: AppColors.champagneGold,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 14),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  data.description,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
