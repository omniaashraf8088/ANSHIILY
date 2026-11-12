import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color deepNavy = Color(0xFF0B132B);
  static const Color champagneGold = Color(0xFFD4AF37);
  static const Color burgundy = Color(0xFF7A0E2C);
  static const Color royalBurgundy = Color(0xFF7A0E2C);
  static const Color warmIvory = Color(0xFFF6E9D8);
  static const Color surfaceNavy = Color(0xFF131D3B);

  static const Color deepNavyLight = Color(0xFF1A2347);
  static const Color deepNavyMid = Color(0xFF111B38);
  static const Color goldGlow = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8960C);
  static const Color burgundyLight = Color(0xFFA01038);

  static const Color transparentGold = Color(0x33D4AF37);
  static const Color transparentGoldMid = Color(0x66D4AF37);
  static const Color transparentBurgundy = Color(0x337A0E2C);
  static const Color transparentWhite = Color(0x1AFFFFFF);

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepNavy, deepNavyLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldGlow, champagneGold, goldDark],
  );
}
