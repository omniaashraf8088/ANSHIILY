import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';

class RecentProjectsCarousel extends StatelessWidget {
  final List<ProjectModel> projects;
  final VoidCallback onRefresh;

  const RecentProjectsCarousel({
    super.key,
    required this.projects,
    required this.onRefresh,
  });

  Future<void> _handleRename(BuildContext context, ProjectModel project) async {
    final controller = TextEditingController(text: project.title);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.champagneGold),
        ),
        title: Text(
          'تعديل اسم المشروع',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.tajawal(color: AppColors.warmIvory),
          decoration: InputDecoration(
            labelText: 'اسم المشروع الجديد',
            labelStyle: GoogleFonts.tajawal(color: AppColors.champagneGold),
            filled: true,
            fillColor: AppColors.deepNavy,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: AppColors.warmIvory),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.champagneGold,
              foregroundColor: AppColors.deepNavy,
            ),
            child: Text(
              'حفظ',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      final success = await ProjectService.instance.renameProject(
        project.id,
        controller.text.trim(),
      );
      if (success) onRefresh();
    }
  }

  Future<void> _handleDuplicate(
    BuildContext context,
    ProjectModel project,
  ) async {
    final dup = await ProjectService.instance.duplicateProject(project.id);
    if (dup != null) {
      onRefresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تكرار المشروع بنجاح: "${dup.title}"',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppColors.champagneGold,
        ),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, ProjectModel project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.champagneGold),
        ),
        title: Text(
          'حذف المشروع',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'هل تريد بالتأكيد حذف "${project.title}" نهائياً؟',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.85),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(color: AppColors.warmIvory),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ProjectService.instance.deleteProject(project.id);
      if (success) onRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.champagneGold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_open_rounded,
                  color: AppColors.champagneGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لا توجد مشروعات حديثة بعد',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'اختر قالباً أو ابدأ فكرة جديدة لتظهر مشروعاتك هنا.',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: projects.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final project = projects[index];
          final dateStr =
              '${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}';

          return Container(
            width: 165,
            decoration: BoxDecoration(
              color: AppColors.surfaceNavy,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.champagneGold.withValues(alpha: 0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Thumbnail with popup menu
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (project.imageUrl != null &&
                          project.imageUrl!.isNotEmpty)
                        Image.network(
                          project.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallback(),
                        )
                      else
                        _buildFallback(),

                      // Top menu button
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.deepNavy.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: AppColors.champagneGold,
                              size: 16,
                            ),
                            color: AppColors.surfaceNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: AppColors.champagneGold.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            onSelected: (val) {
                              switch (val) {
                                case 'open':
                                  context.push(
                                    AppRoutes.projectEditor,
                                    extra: {'project': project},
                                  );
                                  break;
                                case 'rename':
                                  _handleRename(context, project);
                                  break;
                                case 'duplicate':
                                  _handleDuplicate(context, project);
                                  break;
                                case 'delete':
                                  _handleDelete(context, project);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'open',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.edit_rounded,
                                      size: 16,
                                      color: AppColors.champagneGold,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'فتح المشروع',
                                      style: GoogleFonts.tajawal(
                                        color: AppColors.warmIvory,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'rename',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.drive_file_rename_outline,
                                      size: 16,
                                      color: AppColors.champagneGold,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'تغيير الاسم',
                                      style: GoogleFonts.tajawal(
                                        color: AppColors.warmIvory,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'duplicate',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.copy_rounded,
                                      size: 16,
                                      color: AppColors.champagneGold,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'تكرار المشروع',
                                      style: GoogleFonts.tajawal(
                                        color: AppColors.warmIvory,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 16,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'حذف',
                                      style: GoogleFonts.tajawal(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Status Badge
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: project.status == 'completed'
                                ? Colors.green.shade800
                                : AppColors.burgundy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            project.statusDisplayArabic,
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Info Footer
                GestureDetector(
                  onTap: () {
                    context.push(
                      AppRoutes.projectEditor,
                      extra: {'project': project},
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'تعديل: $dateStr',
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.deepNavy,
      child: Center(
        child: Icon(
          Icons.art_track_rounded,
          color: AppColors.champagneGold.withValues(alpha: 0.4),
          size: 28,
        ),
      ),
    );
  }
}
