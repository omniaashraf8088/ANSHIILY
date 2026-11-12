import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routing/app_router.dart';
import '../auth/models/user_profile.dart';
import '../auth/services/auth_service.dart';
import '../categories/widgets/category_card.dart';
import '../projects/models/category_model.dart';
import '../projects/models/project_model.dart';
import '../projects/services/project_service.dart';
import '../templates/models/template_model.dart';
import '../templates/services/template_service.dart';
import '../templates/widgets/template_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_hero_section.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/recent_projects_carousel.dart';
import 'widgets/premium_features_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserProfile? _profile;
  List<CategoryModel> _categories = CategoryModel.defaults;
  List<TemplateModel> _featuredTemplates = TemplateModel.defaults
      .where((t) => t.isFeatured)
      .toList();
  List<TemplateModel> _popularTemplates = TemplateModel.defaults;
  List<ProjectModel> _recentProjects = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final profile = await AuthService.instance.getCurrentProfile();
      final categories = await TemplateService.instance.getCategories();
      final featured = await TemplateService.instance.getFeaturedTemplates();
      final popular = await TemplateService.instance.getPopularTemplates();
      final projects = await ProjectService.instance.getRecentProjects(
        limit: 6,
      );

      if (!mounted) return;
      setState(() {
        _profile = profile;
        if (categories.isNotEmpty) _categories = categories;
        if (featured.isNotEmpty) _featuredTemplates = featured;
        if (popular.isNotEmpty) _popularTemplates = popular;
        _recentProjects = projects;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading dashboard: $e');
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleStartDesign() async {
    context.push(AppRoutes.aiWizard);
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F1B35),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.champagneGold, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'مركز الإشعارات والتحديثات',
                  style: GoogleFonts.tajawal(
                    color: AppColors.champagneGold,
                    fontSize: 18,
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
            const SizedBox(height: 12),
            _buildNotificationItem(
              icon: Icons.star_rounded,
              title: 'تم إطلاق المرحلة 3 بنجاح!',
              time: 'الآن',
              desc:
                  'استكشف 10 تصنيفات تصميمية جديدة ومكتبة القوالب الإبداعية المهيكلة.',
            ),
            const SizedBox(height: 8),
            _buildNotificationItem(
              icon: Icons.auto_awesome_rounded,
              title: 'رصيد إبداعي مجاني مضاف',
              time: 'اليوم',
              desc: 'تمت إضافة 10 نقاط رصيد إبداعي لحسابك لتجربة القوالب.',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required String time,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.champagneGold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.tajawal(
                        color: AppColors.champagneGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory.withValues(alpha: 0.8),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = AuthService.instance.isAuthenticated;

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
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
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: AppColors.champagneGold,
            backgroundColor: AppColors.surfaceNavy,
            child: CustomScrollView(
              slivers: [
                // 1. Header (Logo, welcome, credits, notifications, avatar)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      HomeHeader(
                        profile: _profile,
                        isAuthenticated: isAuthenticated,
                        onProfileTap: () => context.push(AppRoutes.profile),
                        onNotificationsTap: _showNotificationsSheet,
                      ),
                      if (_isLoading)
                        const LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.champagneGold,
                          ),
                          minHeight: 2,
                        ),
                    ],
                  ),
                ),

                // 2. Main Hero Section
                SliverToBoxAdapter(
                  child: HomeHeroSection(onStartDesign: _handleStartDesign),
                ),

                // 3. Section A: Design Categories (تصنيفات التصميم)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تصنيفات التصميم',
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.categories),
                          child: Row(
                            children: [
                              Text(
                                'عرض الكل',
                                style: GoogleFonts.tajawal(
                                  color: AppColors.champagneGold,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 12,
                                color: AppColors.champagneGold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 125,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        return CategoryCard(
                          category: cat,
                          isCompact: true,
                          onTap: () {
                            context.push(
                              '${AppRoutes.templateLibrary}?category=${cat.slug}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // 4. Section B: Featured Templates (قوالب مختارة)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.champagneGold,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'قوالب مختارة',
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.tajawal(
                                color: AppColors.champagneGold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.templateLibrary),
                          child: Text(
                            'المكتبة الكاملة',
                            style: GoogleFonts.tajawal(
                              color: AppColors.champagneGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _featuredTemplates.length,
                      itemBuilder: (context, index) {
                        final tpl = _featuredTemplates[index];
                        return TemplateCard(
                          template: tpl,
                          isHorizontal: true,
                          onTap: () {
                            context.push(
                              '${AppRoutes.templatePreview}/${tpl.id}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // 5. Section C: Recently Edited Projects (مشروعاتك الأخيرة)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.folder_special_rounded,
                              color: AppColors.champagneGold,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'مشروعاتك الأخيرة',
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.tajawal(
                                color: AppColors.champagneGold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_recentProjects.length} مشروع',
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: RecentProjectsCarousel(
                    projects: _recentProjects,
                    onRefresh: _loadDashboardData,
                  ),
                ),

                // 6. Section D: Popular Designs (تصاميم رائجة)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              color: AppColors.champagneGold,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'تصاميم رائجة',
                              textDirection: TextDirection.rtl,
                              style: GoogleFonts.tajawal(
                                color: AppColors.champagneGold,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'الأكثر استخداماً هذا الأسبوع',
                          style: GoogleFonts.tajawal(
                            color: AppColors.warmIvory.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _popularTemplates.length,
                      itemBuilder: (context, index) {
                        final tpl = _popularTemplates[index];
                        return TemplateCard(
                          template: tpl,
                          isHorizontal: true,
                          onTap: () {
                            context.push(
                              '${AppRoutes.templatePreview}/${tpl.id}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // 7. Section E: AI Design Assistant (المساعد الإبداعي الذكي)
                SliverToBoxAdapter(
                  child: AiAssistantCard(
                    categories: _categories,
                    onProjectCreated: _loadDashboardData,
                  ),
                ),

                // 8. Section F: Premium Features (مميزات أنشئلي بريميوم)
                const SliverToBoxAdapter(child: PremiumFeaturesCard()),

                const SliverToBoxAdapter(child: SizedBox(height: 36)),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleStartDesign,
        backgroundColor: AppColors.champagneGold,
        foregroundColor: AppColors.deepNavy,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppStrings.newProject,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
