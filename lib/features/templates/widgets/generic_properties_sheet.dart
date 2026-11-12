import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/document_structure.dart';

class GenericPropertiesSheet extends StatelessWidget {
  final DocumentElement element;
  final ValueChanged<String>? onColorChanged;
  final ValueChanged<double>? onOpacityChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;

  static const List<Map<String, dynamic>> presetColors = [
    {'name': 'عنابي ملكي', 'hex': '#7A0E2C'},
    {'name': 'ذهبي شامبين', 'hex': '#D4AF37'},
    {'name': 'كحلي عميق', 'hex': '#0B132B'},
    {'name': 'عاجي دافئ', 'hex': '#F6E9D8'},
    {'name': 'أخضر زمردي', 'hex': '#2A9D8F'},
    {'name': 'مرجاني', 'hex': '#E76F51'},
    {'name': 'أبيض نقي', 'hex': '#FFFFFF'},
  ];

  const GenericPropertiesSheet({
    super.key,
    required this.element,
    this.onColorChanged,
    this.onOpacityChanged,
    required this.onDuplicate,
    required this.onDelete,
    required this.onBringToFront,
    required this.onSendToBack,
  });

  @override
  Widget build(BuildContext context) {
    final isShape = element.type == 'shape';
    final currentColorHex = element.style['fillColor'] as String? ?? '#7A0E2C';
    final opacity = element.opacity;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppColors.champagneGold, width: 1.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row with Type and Quick Actions
          Row(
            children: [
              Icon(
                element.type == 'image'
                    ? Icons.image_rounded
                    : Icons.category_rounded,
                color: AppColors.champagneGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  element.type == 'image'
                      ? 'صورة (${element.width.round()}×${element.height.round()})'
                      : 'شكل هندسي (${element.width.round()}×${element.height.round()})',
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Duplicate Element
              IconButton(
                icon: const Icon(
                  Icons.content_copy_rounded,
                  color: AppColors.warmIvory,
                  size: 19,
                ),
                tooltip: 'مضاعفة العنصر',
                onPressed: onDuplicate,
              ),
              // Bring to Front
              IconButton(
                icon: const Icon(
                  Icons.flip_to_front_rounded,
                  color: AppColors.warmIvory,
                  size: 19,
                ),
                tooltip: 'إلى المقدمة',
                onPressed: onBringToFront,
              ),
              // Send to Back
              IconButton(
                icon: const Icon(
                  Icons.flip_to_back_rounded,
                  color: AppColors.warmIvory,
                  size: 19,
                ),
                tooltip: 'إلى الخلفية',
                onPressed: onSendToBack,
              ),
              // Delete Element
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: 'حذف العنصر',
                onPressed: onDelete,
              ),
            ],
          ),

          if (isShape && onColorChanged != null) ...[
            const Divider(color: Color(0x22D4AF37), height: 16),
            Text(
              'لون التعبئة (Fill Color):',
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: presetColors.map((cp) {
                  final hex = cp['hex'] as String;
                  final isSelected =
                      currentColorHex.toUpperCase() == hex.toUpperCase();
                  final color = Color(int.parse(hex.replaceAll('#', '0xFF')));

                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => onColorChanged!(hex),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.champagneGold
                                : Colors.white24,
                            width: isSelected ? 2.5 : 1.0,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 12,
                                color: color.computeLuminance() > 0.5
                                    ? Colors.black
                                    : Colors.white,
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          if (onOpacityChanged != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'الشفافية: ${(opacity * 100).round()}%',
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.champagneGold,
                      inactiveTrackColor: AppColors.deepNavy,
                      thumbColor: AppColors.champagneGold,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: opacity.clamp(0.1, 1.0),
                      min: 0.1,
                      max: 1.0,
                      onChanged: onOpacityChanged,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
