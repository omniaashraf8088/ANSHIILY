import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../projects/models/category_model.dart';
import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';
import '../models/template_model.dart';

class TemplateService {
  TemplateService._();
  static final TemplateService instance = TemplateService._();

  SupabaseClient? get _client => SupabaseService.instance.client;

  // In-memory fallback dataset for offline and rapid preview
  final List<TemplateModel> _localTemplates = List.from(TemplateModel.defaults);

  /// Fetch all design categories
  Future<List<CategoryModel>> getCategories() async {
    final client = _client;
    if (client == null) return CategoryModel.defaults;

    try {
      // First try design_categories, then fallback to categories
      final List<dynamic> response = await client
          .from('design_categories')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      if (response.isNotEmpty) {
        return response
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback check on standard categories table
      try {
        final List<dynamic> response = await client
            .from('categories')
            .select()
            .order('created_at', ascending: true);

        if (response.isNotEmpty) {
          final dbSlugs = response.map((r) => r['slug']).toSet();
          final fromDb = response
              .map(
                (item) => CategoryModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          final extraDefaults = CategoryModel.defaults
              .where((d) => !dbSlugs.contains(d.slug))
              .toList();
          return [...fromDb, ...extraDefaults];
        }
      } catch (e) {
        if (kDebugMode) {
          print('Categories fetch notice: $e');
        }
      }
    }

    return CategoryModel.defaults;
  }

  /// Fetch templates with multi-criteria filtering, search and sorting
  Future<List<TemplateModel>> getTemplates({
    String? categorySlug,
    bool? isPremium,
    bool? isFeatured,
    String? searchQuery,
    String? sortBy, // 'popularity', 'newest'
  }) async {
    final client = _client;

    List<TemplateModel> templates = [];

    if (client != null) {
      try {
        var filterQuery = client.from('design_templates').select();

        if (categorySlug != null && categorySlug != 'all') {
          filterQuery = filterQuery.eq('category_slug', categorySlug);
        }
        if (isPremium != null) {
          filterQuery = filterQuery.eq('is_premium', isPremium);
        }
        if (isFeatured != null) {
          filterQuery = filterQuery.eq('is_featured', isFeatured);
        }

        final List<dynamic> response = sortBy == 'popularity'
            ? await filterQuery.order('popularity_score', ascending: false)
            : await filterQuery.order('created_at', ascending: false);
        if (response.isNotEmpty) {
          templates = response
              .map(
                (item) => TemplateModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Templates DB notice: $e (using rich seed templates)');
        }
      }
    }

    if (templates.isEmpty) {
      templates = List.from(_localTemplates);
    }

    // Apply client-side filters if needed
    if (categorySlug != null && categorySlug != 'all') {
      templates = templates
          .where((t) => t.categorySlug == categorySlug)
          .toList();
    }
    if (isPremium != null) {
      templates = templates.where((t) => t.isPremium == isPremium).toList();
    }
    if (isFeatured != null && isFeatured) {
      templates = templates.where((t) => t.isFeatured).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      templates = templates.where((t) {
        return t.nameAr.toLowerCase().contains(q) ||
            t.nameEn.toLowerCase().contains(q) ||
            t.descriptionAr.toLowerCase().contains(q);
      }).toList();
    }

    // Sort
    if (sortBy == 'popularity') {
      templates.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
    } else {
      templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return templates;
  }

  /// Get featured templates for home hero section
  Future<List<TemplateModel>> getFeaturedTemplates() async {
    return getTemplates(isFeatured: true);
  }

  /// Get popular templates
  Future<List<TemplateModel>> getPopularTemplates() async {
    return getTemplates(sortBy: 'popularity');
  }

  /// Get template by ID
  Future<TemplateModel?> getTemplateById(String id) async {
    final client = _client;
    if (client != null) {
      try {
        final data = await client
            .from('design_templates')
            .select()
            .eq('id', id)
            .maybeSingle();

        if (data != null) {
          return TemplateModel.fromJson(data);
        }
      } catch (_) {}
    }

    final local = _localTemplates.where((t) => t.id == id);
    if (local.isNotEmpty) return local.first;
    return null;
  }

  /// Create a new project from a structured template
  Future<ProjectModel?> createProjectFromTemplate(
    TemplateModel template, {
    String? customTitle,
  }) async {
    final title = customTitle ?? 'مشروع: ${template.nameAr}';
    final prompt =
        'مستند مصمم بناءً على قالب "${template.nameAr}" (${template.dimensionsString})';

    final createdProject = await ProjectService.instance.createProject(
      title: title,
      prompt: prompt,
      style: template.categorySlug,
      aspectRatio: template.width == template.height
          ? '1:1'
          : template.width > template.height
          ? '16:9'
          : '9:16',
      imageUrl: template.previewUrl,
    );

    return createdProject;
  }
}
