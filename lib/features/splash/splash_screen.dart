import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routing/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _waveController;

  // Wave animations (continuous)
  late Animation<double> _waveAnimation;

  // Staged reveal animations
  late Animation<double> _goldWaveFade;
  late Animation<double> _burgundyWaveFade;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _arabicNameOffset;
  late Animation<double> _arabicNameFade;
  late Animation<double> _englishNameFade;
  late Animation<double> _taglineFade;
  late Animation<double> _screenFadeOut;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_waveController);

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    // Golden wave: 0.0 → 0.3
    _goldWaveFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Burgundy wave: 0.2 → 0.4
    _burgundyWaveFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.42, curve: Curves.easeIn),
      ),
    );

    // Logo scale + fade: 0.3 → 0.6
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.62, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.55, curve: Curves.easeOut),
      ),
    );

    // Arabic name slide up + fade: 0.5 → 0.75
    _arabicNameOffset = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _arabicNameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );

    // English name fade: 0.65 → 0.82
    _englishNameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 0.82, curve: Curves.easeOut),
      ),
    );

    // Tagline fade: 0.75 → 0.92
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.75, 0.92, curve: Curves.easeOut),
      ),
    );

    // Screen fade out: 0.90 → 1.0
    _screenFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.90, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animation then navigate
    _mainController.forward().then((_) {
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = math.min(size.width, size.height);
    final logoSize = (shortestSide * 0.32).clamp(84.0, 140.0);
    final glowSize = logoSize * 1.35;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _waveController]),
        builder: (context, child) {
          return Stack(
            children: [
              // Background gradient
              Container(
                width: size.width,
                height: size.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0B132B),
                      Color(0xFF0F1B35),
                      Color(0xFF0B132B),
                    ],
                  ),
                ),
              ),

              // Golden wave layer
              Opacity(
                opacity: _goldWaveFade.value,
                child: CustomPaint(
                  size: size,
                  painter: _WavePainter(
                    animValue: _waveAnimation.value,
                    goldOpacity: _goldWaveFade.value,
                    burgundyOpacity: 0,
                    showBurgundy: false,
                  ),
                ),
              ),

              // Burgundy wave layer
              Opacity(
                opacity: _burgundyWaveFade.value,
                child: CustomPaint(
                  size: size,
                  painter: _WavePainter(
                    animValue: _waveAnimation.value,
                    goldOpacity: 0,
                    burgundyOpacity: _burgundyWaveFade.value,
                    showBurgundy: true,
                  ),
                ),
              ),

              // Center content with FittedBox to prevent any overflow on small/landscape screens
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo with glow
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow effect behind logo
                                  Container(
                                    width: glowSize,
                                    height: glowSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.champagneGold
                                              .withValues(
                                                alpha: 0.15 * _logoFade.value,
                                              ),
                                          blurRadius: 50,
                                          spreadRadius: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // The golden A symbol with rounded corners
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.asset(
                                      AppAssets.appIcon,
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Arabic brand name
                          Transform.translate(
                            offset: Offset(0, _arabicNameOffset.value),
                            child: Opacity(
                              opacity: _arabicNameFade.value,
                              child: Text(
                                AppStrings.appNameArabic,
                                textDirection: TextDirection.rtl,
                                style: GoogleFonts.tajawal(
                                  color: AppColors.champagneGold,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.champagneGold.withValues(
                                        alpha: 0.6,
                                      ),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 6),

                          // English brand name
                          Opacity(
                            opacity: _englishNameFade.value,
                            child: Text(
                              AppStrings.appName,
                              style: GoogleFonts.cormorantGaramond(
                                color: AppColors.champagneGold,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 8.0,
                                shadows: [
                                  Shadow(
                                    color: AppColors.champagneGold.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Divider line
                          Opacity(
                            opacity: _taglineFade.value,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 1,
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.star,
                                  color: AppColors.champagneGold,
                                  size: 10,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 44,
                                  height: 1,
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Arabic tagline
                          Opacity(
                            opacity: _taglineFade.value,
                            child: Text(
                              AppStrings.taglineArabic,
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.tajawal(
                                color: AppColors.warmIvory.withValues(
                                  alpha: 0.85,
                                ),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // English tagline
                          Opacity(
                            opacity: _taglineFade.value,
                            child: Text(
                              AppStrings.taglineEnglish,
                              style: GoogleFonts.cormorantGaramond(
                                color: AppColors.warmIvory.withValues(
                                  alpha: 0.65,
                                ),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Fade-out overlay for transition
              if (_screenFadeOut.value > 0)
                Opacity(
                  opacity: _screenFadeOut.value,
                  child: Container(color: AppColors.deepNavy),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Custom painter for animated sine waves
class _WavePainter extends CustomPainter {
  final double animValue;
  final double goldOpacity;
  final double burgundyOpacity;
  final bool showBurgundy;

  _WavePainter({
    required this.animValue,
    required this.goldOpacity,
    required this.burgundyOpacity,
    required this.showBurgundy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showBurgundy) {
      _drawBurgundyWave(canvas, size);
    } else {
      _drawGoldWave(canvas, size, 1);
      _drawGoldWave(canvas, size, 2);
    }
  }

  void _drawGoldWave(Canvas canvas, Size size, int waveIndex) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = waveIndex == 1 ? 1.5 : 1.0
      ..color = AppColors.champagneGold.withValues(
        alpha: (waveIndex == 1 ? 0.35 : 0.2) * goldOpacity,
      );

    final path = Path();
    final amplitude = size.height * (waveIndex == 1 ? 0.08 : 0.05);
    final frequency = waveIndex == 1 ? 1.5 : 2.0;
    final phaseShift = waveIndex == 1 ? 0.0 : math.pi / 3;
    final yBase = waveIndex == 1 ? size.height * 0.18 : size.height * 0.12;

    path.moveTo(0, yBase);
    for (double x = 0; x <= size.width; x++) {
      final y =
          yBase +
          amplitude *
              math.sin(
                (x / size.width * frequency * 2 * math.pi) +
                    animValue +
                    phaseShift,
              );
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Mirror wave at bottom
    final path2 = Path();
    final yBase2 = size.height - yBase;
    path2.moveTo(0, yBase2);
    for (double x = 0; x <= size.width; x++) {
      final y =
          yBase2 -
          amplitude *
              math.sin(
                (x / size.width * frequency * 2 * math.pi) +
                    animValue +
                    phaseShift,
              );
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint);
  }

  void _drawBurgundyWave(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.burgundy.withValues(alpha: 0.18 * burgundyOpacity);

    final path = Path();
    final yBase = size.height * 0.88;
    final amplitude = size.height * 0.04;

    path.moveTo(0, size.height);
    path.lineTo(0, yBase);
    for (double x = 0; x <= size.width; x++) {
      final y =
          yBase +
          amplitude *
              math.sin((x / size.width * 2.5 * 2 * math.pi) + animValue * 0.7);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);

    // Second burgundy stroke wave
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.burgundy.withValues(alpha: 0.4 * burgundyOpacity);

    final strokePath = Path();
    final yBase2 = size.height * 0.84;
    strokePath.moveTo(0, yBase2);
    for (double x = 0; x <= size.width; x++) {
      final y =
          yBase2 +
          amplitude *
              0.8 *
              math.sin(
                (x / size.width * 2 * 2 * math.pi) +
                    animValue * 0.8 +
                    math.pi / 4,
              );
      strokePath.lineTo(x, y);
    }
    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) =>
      oldDelegate.animValue != animValue ||
      oldDelegate.goldOpacity != goldOpacity ||
      oldDelegate.burgundyOpacity != burgundyOpacity;
}
