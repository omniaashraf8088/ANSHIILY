import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../projects/models/category_model.dart';
import '../models/template_model.dart';
import '../services/template_service.dart';
import '../widgets/template_card.dart';

class TemplateLibraryScreen extends StatefulWidget {
  final String? initialCategory;

  const TemplateLibraryScreen({super.key, this.initialCategory});

  @override
  State<TemplateLibraryScreen> createState() => _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState extends State<TemplateLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<CategoryModel> _categories = [];
  List<TemplateModel> _templates = [];
  bool _isLoading = true;

  String _selectedCategorySlug = 'all';
  String _selectedTier = 'all'; // 'all', 'free', 'premium'
  String _selectedSort = 'popularity'; // 'popularity', 'newest'

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _selectedCategorySlug = widget.initialCategory!;
    }
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      TemplateService.instance.getCategories(),
      TemplateService.instance.getTemplates(
        categorySlug: _selectedCategorySlug,
        isPremium: _selectedTier == 'free'
            ? false
            : _selectedTier == 'premium'
            ? true
            : null,
        sortBy: _selectedSort,
        searchQuery: _searchController.text,
      ),
    ]);

    if (!mounted) return;
    setState(() {
      _categories = results[0] as List<CategoryModel>;
      _templates = results[1] as List<TemplateModel>;
      _isLoading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategorySlug = 'all';
      _selectedTier = 'all';
      _selectedSort = 'popularity';
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceNavy,
        elevation: 0,
        title: Text(
          'مكتبة القوالب الإبداعية',
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.champagneGold,
            ),
            tooltip: 'تحديث',
            onPressed: _loadData,
          ),
        ],
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) => _loadData(),
                style: GoogleFonts.tajawal(color: AppColors.warmIvory),
                decoration: InputDecoration(
                  hintText: 'ابحث عن قالب بالاسم أو الوصف...',
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.warmIvory,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _loadData();
                          },
                        )
                      : null,
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

            // Tier & Sort Controls Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  // Free / Premium filter
                  _buildSmallFilterChip('الكل', 'all', _selectedTier, (val) {
                    setState(() => _selectedTier = val);
                    _loadData();
                  }),
                  const SizedBox(width: 6),
                  _buildSmallFilterChip('مجاني', 'free', _selectedTier, (val) {
                    setState(() => _selectedTier = val);
                    _loadData();
                  }),
                  const SizedBox(width: 6),
                  _buildSmallFilterChip('بريميوم ★', 'premium', _selectedTier, (
                    val,
                  ) {
                    setState(() => _selectedTier = val);
                    _loadData();
                  }),

                  const Spacer(),

                  // Sort Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceNavy,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.champagneGold.withValues(alpha: 0.25),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        dropdownColor: AppColors.surfaceNavy,
                        icon: const Icon(
                          Icons.sort_rounded,
                          color: AppColors.champagneGold,
                          size: 18,
                        ),
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'popularity',
                            child: Text('الأكثر شعبية'),
                          ),
                          DropdownMenuItem(
                            value: 'newest',
                            child: Text('الأحدث إضافة'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedSort = val);
                            _loadData();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Categories Filter Chips
            Container(
              height: 44,
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildCategoryChip('كافة التصنيفات', 'all'),
                  ..._categories.map(
                    (c) => _buildCategoryChip(c.nameAr, c.slug),
                  ),
                ],
              ),
            ),

            // Active Filters Status & Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_templates.length} قالب متوفر',
                    style: GoogleFonts.tajawal(
                      color: AppColors.warmIvory.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                  if (_selectedCategorySlug != 'all' ||
                      _selectedTier != 'all' ||
                      _searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearFilters,
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_alt_off_rounded,
                            size: 14,
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'مسح التصفية',
                            style: GoogleFonts.tajawal(
                              color: AppColors.champagneGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Templates Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.champagneGold,
                      ),
                    )
                  : _templates.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      itemCount: _templates.length,
                      itemBuilder: (context, index) {
                        final template = _templates[index];
                        return TemplateCard(
                          template: template,
                          onTap: () {
                            context.push(
                              '${AppRoutes.templatePreview}/${template.id}',
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

  Widget _buildSmallFilterChip(
    String label,
    String value,
    String selectedValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.champagneGold : AppColors.surfaceNavy,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.champagneGold
                : AppColors.champagneGold.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            color: isSelected ? AppColors.deepNavy : AppColors.warmIvory,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String slug) {
    final isSelected = _selectedCategorySlug == slug;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.tajawal(
            color: isSelected ? AppColors.deepNavy : AppColors.warmIvory,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.champagneGold,
        backgroundColor: AppColors.surfaceNavy,
        side: BorderSide(
          color: isSelected
              ? AppColors.champagneGold
              : AppColors.champagneGold.withValues(alpha: 0.2),
        ),
        showCheckmark: false,
        onSelected: (selected) {
          setState(() => _selectedCategorySlug = slug);
          _loadData();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.champagneGold.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.champagneGold.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.champagneGold,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد قوالب مطابقة',
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'جرب البحث بكلمات أخرى أو اختر تصنيفاً مختلفاً.',
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _clearFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.champagneGold,
                foregroundColor: AppColors.deepNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'عرض كافة القوالب',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
