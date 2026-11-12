import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/document_structure.dart';
import '../utils/editor_font_helper.dart';

class TextPropertiesSheet extends StatelessWidget {
  final DocumentElement element;
  final ValueChanged<String> onContentChanged;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<bool> onBoldToggled;
  final ValueChanged<bool> onItalicToggled;
  final ValueChanged<String> onAlignmentChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onBringToFront;
  final VoidCallback onSendToBack;

  static const List<Map<String, dynamic>> presetColors = [
    {'name': 'ذهبي شامبين', 'hex': '#D4AF37'},
    {'name': 'عاجي دافئ', 'hex': '#F6E9D8'},
    {'name': 'أبيض نقي', 'hex': '#FFFFFF'},
    {'name': 'كحلي عميق', 'hex': '#0B132B'},
    {'name': 'عنابي ملكي', 'hex': '#7A0E2C'},
    {'name': 'أخضر زمردي', 'hex': '#2A9D8F'},
    {'name': 'مرجاني', 'hex': '#E76F51'},
    {'name': 'برونزي فاخر', 'hex': '#C5A059'},
    {'name': 'رمادي داكن', 'hex': '#222222'},
  ];

  const TextPropertiesSheet({
    super.key,
    required this.element,
    required this.onContentChanged,
    required this.onFontFamilyChanged,
    required this.onFontSizeChanged,
    required this.onColorChanged,
    required this.onBoldToggled,
    required this.onItalicToggled,
    required this.onAlignmentChanged,
    required this.onDuplicate,
    required this.onDelete,
    required this.onBringToFront,
    required this.onSendToBack,
  });

  @override
  Widget build(BuildContext context) {
    final style = element.style;
    final currentFontFamily = style['fontFamily'] as String? ?? 'Tajawal';
    final currentFontSize = (style['fontSize'] as num?)?.toDouble() ?? 24.0;
    final currentColorHex = style['color'] as String? ?? '#D4AF37';
    final isBold =
        style['fontWeight'] == 'bold' || style['fontWeight'] == '800';
    final isItalic = style['fontStyle'] == 'italic';
    final alignment = style['textAlign'] as String? ?? 'center';

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
          // Header Row with Edit Content Button and Actions
          Row(
            children: [
              const Icon(
                Icons.text_fields_rounded,
                color: AppColors.champagneGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  element.content.isEmpty ? '(نص فارغ)' : element.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Edit Content Button
              IconButton(
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: AppColors.champagneGold,
                  size: 22,
                ),
                tooltip: 'تعديل النص',
                onPressed: () => _showTextContentDialog(context),
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

          const Divider(color: Color(0x22D4AF37), height: 16),

          // 1. Font Family Horizontal Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: EditorFontHelper.availableFonts.map((font) {
                final isSelected =
                    font.id.toLowerCase() == currentFontFamily.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(
                      font.displayNameAr,
                      style: EditorFontHelper.getTextStyle(
                        font.id,
                        fontSize: 11,
                        color: isSelected
                            ? AppColors.deepNavy
                            : AppColors.warmIvory,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.champagneGold,
                    backgroundColor: AppColors.deepNavy,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.champagneGold
                          : AppColors.champagneGold.withValues(alpha: 0.25),
                    ),
                    onSelected: (_) => onFontFamilyChanged(font.id),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 2. Font Size Slider & Controls
          Row(
            children: [
              Text(
                'الحجم: ${currentFontSize.round()}pt',
                style: GoogleFonts.tajawal(
                  color: AppColors.warmIvory,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  final newSize = (currentFontSize - 2).clamp(12.0, 100.0);
                  onFontSizeChanged(newSize);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.remove,
                    size: 14,
                    color: AppColors.champagneGold,
                  ),
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
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: currentFontSize.clamp(12.0, 100.0),
                    min: 12.0,
                    max: 100.0,
                    onChanged: onFontSizeChanged,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  final newSize = (currentFontSize + 2).clamp(12.0, 100.0);
                  onFontSizeChanged(newSize);
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 14,
                    color: AppColors.champagneGold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 3. Formatting Toggles (Bold, Italic, Alignment)
          Row(
            children: [
              // Bold Toggle
              _buildToggleButton(
                icon: Icons.format_bold_rounded,
                tooltip: 'عريض (Bold)',
                isActive: isBold,
                onTap: () => onBoldToggled(!isBold),
              ),
              const SizedBox(width: 6),

              // Italic Toggle
              _buildToggleButton(
                icon: Icons.format_italic_rounded,
                tooltip: 'مائل (Italic)',
                isActive: isItalic,
                onTap: () => onItalicToggled(!isItalic),
              ),
              const SizedBox(width: 14),

              // Alignment Buttons
              _buildToggleButton(
                icon: Icons.format_align_right_rounded,
                tooltip: 'محاذاة لليمين',
                isActive: alignment == 'right',
                onTap: () => onAlignmentChanged('right'),
              ),
              const SizedBox(width: 6),
              _buildToggleButton(
                icon: Icons.format_align_center_rounded,
                tooltip: 'محاذاة في المنتصف',
                isActive: alignment == 'center',
                onTap: () => onAlignmentChanged('center'),
              ),
              const SizedBox(width: 6),
              _buildToggleButton(
                icon: Icons.format_align_left_rounded,
                tooltip: 'محاذاة لليسار',
                isActive: alignment == 'left',
                onTap: () => onAlignmentChanged('left'),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 4. Color Palette
          SizedBox(
            height: 30,
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
                    onTap: () => onColorChanged(hex),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.champagneGold
                              : Colors.white24,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.6,
                                  ),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14,
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
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String tooltip,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.champagneGold : AppColors.deepNavy,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? AppColors.champagneGold
                  : AppColors.champagneGold.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.deepNavy : AppColors.warmIvory,
          ),
        ),
      ),
    );
  }

  void _showTextContentDialog(BuildContext context) {
    final controller = TextEditingController(text: element.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.champagneGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.edit_rounded,
              color: AppColors.champagneGold,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'تعديل محتوى النص',
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          textDirection: TextDirection.rtl,
          autofocus: true,
          style: GoogleFonts.tajawal(color: AppColors.warmIvory, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'اكتب النص هنا...',
            hintStyle: GoogleFonts.tajawal(color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.champagneGold.withValues(alpha: 0.4),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.champagneGold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newContent = controller.text.trim();
              onContentChanged(newContent);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.deepNavy,
            ),
            child: Text(
              'تطبيق',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
