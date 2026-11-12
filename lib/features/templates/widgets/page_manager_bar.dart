import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/document_structure.dart';

class PageManagerBar extends StatelessWidget {
  final List<DocumentPage> pages;
  final int currentPageIndex;
  final ValueChanged<int> onSelectPage;
  final VoidCallback onAddPage;
  final VoidCallback onDuplicatePage;
  final VoidCallback onDeletePage;

  const PageManagerBar({
    super.key,
    required this.pages,
    required this.currentPageIndex,
    required this.onSelectPage,
    required this.onAddPage,
    required this.onDuplicatePage,
    required this.onDeletePage,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete = pages.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceNavy.withValues(alpha: 0.95),
        border: const Border(
          bottom: BorderSide(color: Color(0x22D4AF37), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Current Page Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.champagneGold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.champagneGold,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'الصفحة ${currentPageIndex + 1} من ${pages.length}',
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Horizontal Page Thumbnails / Selectors
          Expanded(
            child: SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final isSelected = index == currentPageIndex;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: ChoiceChip(
                      label: Text(
                        'ص ${index + 1}',
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.deepNavy
                              : AppColors.warmIvory,
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
                      onSelected: (_) => onSelectPage(index),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Add Page Button
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.champagneGold,
              size: 22,
            ),
            tooltip: 'إضافة صفحة جديدة',
            visualDensity: VisualDensity.compact,
            onPressed: onAddPage,
          ),

          // Duplicate Page Button
          IconButton(
            icon: const Icon(
              Icons.copy_rounded,
              color: AppColors.champagneGold,
              size: 19,
            ),
            tooltip: 'مضاعفة الصفحة الحالية',
            visualDensity: VisualDensity.compact,
            onPressed: onDuplicatePage,
          ),

          // Delete Page Button
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: canDelete
                  ? Colors.redAccent
                  : AppColors.warmIvory.withValues(alpha: 0.25),
              size: 20,
            ),
            tooltip: canDelete
                ? 'حذف الصفحة الحالية'
                : 'لا يمكن حذف الصفحة الوحيدة',
            visualDensity: VisualDensity.compact,
            onPressed: canDelete ? onDeletePage : null,
          ),
        ],
      ),
    );
  }
}
