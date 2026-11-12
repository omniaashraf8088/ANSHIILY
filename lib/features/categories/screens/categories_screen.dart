import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../projects/models/category_model.dart';
import '../../templates/services/template_service.dart';
import '../widgets/category_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final cats = await TemplateService.instance.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = cats;
      _isLoading = false;
    });
  }

  List<CategoryModel> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return _categories;
    final q = _searchQuery.trim().toLowerCase();
    return _categories.where((c) {
      return c.nameAr.toLowerCase().contains(q) ||
          c.nameEn.toLowerCase().contains(q) ||
          (c.descriptionAr?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNavy,
        elevation: 0,
        title: Text(
          'تصنيفات التصميم',
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.champagneGold,
          ),
          onPressed: () => context.pop(),
        ),
      ),
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
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: GoogleFonts.tajawal(color: AppColors.warmIvory),
                decoration: InputDecoration(
                  hintText: 'ابحث في تصنيفات التصميم...',
                  hintStyle: GoogleFonts.tajawal(
                    color: AppColors.warmIvory.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceNavy,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.champagneGold,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
            ),

            // Categories List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.champagneGold,
                      ),
                    )
                  : _filteredCategories.isEmpty
                  ? Center(
                      child: Text(
                        'لم يتم العثور على تصنيفات مطابقة',
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory.withValues(alpha: 0.6),
                          fontSize: 15,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: _filteredCategories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final cat = _filteredCategories[index];
                        return CategoryCard(
                          category: cat,
                          onTap: () {
                            context.push(
                              '${AppRoutes.templateLibrary}?category=${cat.slug}',
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
