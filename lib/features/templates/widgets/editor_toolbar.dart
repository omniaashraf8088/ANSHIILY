import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/editor_state_types.dart';

class EditorToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final AutosaveStatus autosaveStatus;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onAiRefine;
  final VoidCallback onManualSave;
  final VoidCallback onExport;
  final VoidCallback onBack;

  const EditorToolbar({
    super.key,
    required this.title,
    required this.autosaveStatus,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.onAiRefine,
    required this.onManualSave,
    required this.onExport,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surfaceNavy,
      elevation: 0,
      centerTitle: true,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.champagneGold,
          size: 18,
        ),
        visualDensity: VisualDensity.compact,
        tooltip: 'رجوع للرئيسية',
        onPressed: onBack,
      ),
      title: SizedBox(
        width: 120,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            _buildAutosaveBadge(),
          ],
        ),
      ),
      actions: [
        // Undo Action
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(4),
          icon: Icon(
            Icons.undo_rounded,
            color: canUndo
                ? AppColors.champagneGold
                : AppColors.champagneGold.withValues(alpha: 0.3),
            size: 20,
          ),
          tooltip: 'تراجع (Undo)',
          onPressed: canUndo ? onUndo : null,
        ),

        // Redo Action
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(4),
          icon: Icon(
            Icons.redo_rounded,
            color: canRedo
                ? AppColors.champagneGold
                : AppColors.champagneGold.withValues(alpha: 0.3),
            size: 20,
          ),
          tooltip: 'إعادة (Redo)',
          onPressed: canRedo ? onRedo : null,
        ),

        // AI Refinement Button
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(4),
          icon: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.champagneGold,
            size: 20,
          ),
          tooltip: 'تعديل ذكي بالـ AI',
          onPressed: onAiRefine,
        ),

        // Export Button
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(4),
          icon: const Icon(
            Icons.file_download_rounded,
            color: AppColors.champagneGold,
            size: 21,
          ),
          tooltip: 'تصدير التصميم (Export)',
          onPressed: onExport,
        ),

        // Manual Save Button
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(4),
          icon: autosaveStatus == AutosaveStatus.saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.champagneGold,
                  ),
                )
              : const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.champagneGold,
                  size: 20,
                ),
          tooltip: 'حفظ يدوي في السحابة',
          onPressed: onManualSave,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildAutosaveBadge() {
    Color dotColor;
    String text;
    Widget? customIcon;

    switch (autosaveStatus) {
      case AutosaveStatus.saving:
        dotColor = AppColors.champagneGold;
        text = 'جاري الحفظ التلقائي...';
        customIcon = const SizedBox(
          width: 8,
          height: 8,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.champagneGold,
          ),
        );
        break;
      case AutosaveStatus.saved:
        dotColor = Colors.greenAccent;
        text = 'محفوظ تلقائياً ☁️';
        break;
      case AutosaveStatus.unsaved:
        dotColor = Colors.orangeAccent;
        text = 'تعديلات غير محفوظة';
        break;
      case AutosaveStatus.error:
        dotColor = Colors.redAccent;
        text = 'فشل الحفظ ⚠️';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        customIcon ??
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
        const SizedBox(width: 5),
        Text(
          text,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.75),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
