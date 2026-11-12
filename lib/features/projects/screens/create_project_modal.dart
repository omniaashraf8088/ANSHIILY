import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/category_model.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class CreateProjectModal extends StatefulWidget {
  final List<CategoryModel> categories;
  final String? initialPrompt;

  const CreateProjectModal({
    super.key,
    required this.categories,
    this.initialPrompt,
  });

  static Future<ProjectModel?> show(
    BuildContext context, {
    required List<CategoryModel> categories,
    String? initialPrompt,
  }) {
    return showModalBottomSheet<ProjectModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateProjectModal(
        categories: categories,
        initialPrompt: initialPrompt,
      ),
    );
  }

  @override
  State<CreateProjectModal> createState() => _CreateProjectModalState();
}

class _CreateProjectModalState extends State<CreateProjectModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _promptController;

  String _selectedStyle = 'فاخر ذهبي';
  String _selectedAspectRatio = '1:1';
  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPrompt ?? '';
    _promptController = TextEditingController(text: initial);
    final firstLine = initial.split('\n').first.trim();
    _titleController = TextEditingController(text: firstLine);
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first.nameAr;
    }
  }

  final List<String> _styles = const [
    'فاخر ذهبي',
    'عصري مينيمال',
    'خط عربي أصيل',
    'ثلاثي الأبعاد 3D',
    'نيون تكنولوجي',
    'تجريدي حديث',
  ];

  final List<Map<String, String>> _aspectRatios = const [
    {'label': 'مربع 1:1', 'value': '1:1'},
    {'label': 'ستوري 9:16', 'value': '9:16'},
    {'label': 'شاشة 16:9', 'value': '16:9'},
    {'label': 'بوست 4:5', 'value': '4:5'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final project = await ProjectService.instance.createProject(
        title: _titleController.text.trim(),
        prompt: _promptController.text.trim(),
        style: _selectedStyle,
        aspectRatio: _selectedAspectRatio,
      );

      if (!mounted) return;
      Navigator.pop(context, project);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء حفظ المشروع: $e',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1B35),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: AppColors.champagneGold, width: 1.5),
          ),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.champagneGold.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.createNewProject,
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.champagneGold,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Project Title input
                Text(
                  AppStrings.projectTitle,
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory,
                    fontSize: 15,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم المشروع';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.projectTitleHint,
                    hintStyle: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.35),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceNavy,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.champagneGold.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.champagneGold.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.champagneGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Prompt input
                Text(
                  AppStrings.projectPrompt,
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _promptController,
                  maxLines: 3,
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory,
                    fontSize: 15,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى وصف فكرة التصميم';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: AppStrings.projectPromptHint,
                    hintStyle: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.35),
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceNavy,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.champagneGold.withValues(alpha: 0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: AppColors.champagneGold.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.champagneGold,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Category Selector
                if (widget.categories.isNotEmpty) ...[
                  Text(
                    AppStrings.category,
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.categories.map((cat) {
                      final isSelected = _selectedCategory == cat.nameAr;
                      return ChoiceChip(
                        label: Text(
                          cat.nameAr,
                          style: GoogleFonts.tajawal(
                            color: isSelected
                                ? AppColors.deepNavy
                                : AppColors.warmIvory,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.champagneGold,
                        backgroundColor: AppColors.surfaceNavy,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.champagneGold
                              : AppColors.champagneGold.withValues(alpha: 0.25),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat.nameAr);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                ],

                // Style Selector
                Text(
                  AppStrings.style,
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _styles.map((style) {
                    final isSelected = _selectedStyle == style;
                    return ChoiceChip(
                      label: Text(
                        style,
                        style: GoogleFonts.tajawal(
                          color: isSelected
                              ? AppColors.deepNavy
                              : AppColors.warmIvory,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.champagneGold,
                      backgroundColor: AppColors.surfaceNavy,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.champagneGold
                            : AppColors.champagneGold.withValues(alpha: 0.25),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedStyle = style);
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // Aspect Ratio Selector
                Text(
                  AppStrings.aspectRatio,
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _aspectRatios.map((item) {
                    final isSelected = _selectedAspectRatio == item['value'];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedAspectRatio = item['value']!,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.champagneGold
                                : AppColors.surfaceNavy,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.champagneGold
                                  : AppColors.champagneGold.withValues(
                                      alpha: 0.25,
                                    ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item['label']!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.tajawal(
                                color: isSelected
                                    ? AppColors.deepNavy
                                    : AppColors.warmIvory,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.champagneGold,
                      foregroundColor: AppColors.deepNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.deepNavy,
                            ),
                          )
                        : Text(
                            AppStrings.create,
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
