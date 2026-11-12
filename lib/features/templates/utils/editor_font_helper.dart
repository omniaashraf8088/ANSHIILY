import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditorFontOption {
  final String id;
  final String displayNameAr;
  final String displayNameEn;

  const EditorFontOption({
    required this.id,
    required this.displayNameAr,
    required this.displayNameEn,
  });
}

class EditorFontHelper {
  EditorFontHelper._();

  static const List<EditorFontOption> availableFonts = [
    EditorFontOption(
      id: 'Tajawal',
      displayNameAr: 'تجوال (فاخر)',
      displayNameEn: 'Tajawal',
    ),
    EditorFontOption(
      id: 'Cairo',
      displayNameAr: 'القاهرة (عصري)',
      displayNameEn: 'Cairo',
    ),
    EditorFontOption(
      id: 'Almarai',
      displayNameAr: 'المراعي (ناعم)',
      displayNameEn: 'Almarai',
    ),
    EditorFontOption(
      id: 'Amiri',
      displayNameAr: 'أميري (كلاسيكي)',
      displayNameEn: 'Amiri',
    ),
    EditorFontOption(
      id: 'Alexandria',
      displayNameAr: 'الإسكندرية (أنيق)',
      displayNameEn: 'Alexandria',
    ),
    EditorFontOption(
      id: 'Readex Pro',
      displayNameAr: 'ريدكس برو (حديث)',
      displayNameEn: 'Readex Pro',
    ),
  ];

  static TextStyle getTextStyle(
    String? fontFamily, {
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? height,
    List<Shadow>? shadows,
  }) {
    final family = fontFamily?.toLowerCase().trim() ?? 'tajawal';

    // In headless test environments, avoid triggering remote HTTP font downloads
    if (WidgetsBinding.instance.runtimeType.toString().contains('TestWidgetsFlutterBinding')) {
      return TextStyle(
        fontFamily: family,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        shadows: shadows,
      );
    }

    try {
      switch (family) {
        case 'cairo':
          return GoogleFonts.cairo(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            height: height,
            shadows: shadows,
          );
        case 'almarai':
          return GoogleFonts.almarai(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            height: height,
            shadows: shadows,
          );
        case 'amiri':
          return GoogleFonts.amiri(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            height: height,
            shadows: shadows,
          );
        case 'alexandria':
          return GoogleFonts.alexandria(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            height: height,
            shadows: shadows,
          );
        case 'readex pro':
        case 'readexpro':
          return GoogleFonts.readexPro(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            height: height,
            shadows: shadows,
          );
        case 'tajawal':
        default:
          return GoogleFonts.tajawal(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            height: height,
            shadows: shadows,
          );
      }
    } catch (_) {
      return TextStyle(
        fontFamily: family,
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: height,
        shadows: shadows,
      );
    }
  }
}
