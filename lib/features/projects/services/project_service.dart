import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/category_model.dart';
import '../models/project_model.dart';

class ProjectService {
  ProjectService._();
  static final ProjectService instance = ProjectService._();

  SupabaseClient? get _client => SupabaseService.instance.client;

  // In-memory demo store for guest mode or offline fallback
  final List<ProjectModel> _demoProjects = [
    ProjectModel(
      id: 'demo-1',
      userId: 'demo-user',
      title: 'شعار فخم لعلامة عطور عربية',
      prompt:
          'شعار ذهبي مائل للأناقة الملكية مع لمسات خط كوفي حديث وخلفية كحلية داكنة.',
      status: 'completed',
      style: 'فاخر ذهبي',
      aspectRatio: '1:1',
      imageUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ProjectModel(
      id: 'demo-2',
      userId: 'demo-user',
      title: 'تصميم واجهة متجر مجوهرات',
      prompt:
          'واجهة تطبيق جوال راقية لعرض الخواتم والأساور بأسلوب مينيمال داكن مع تفاصيل ذهبية.',
      status: 'draft',
      style: 'عصري مينيمال',
      aspectRatio: '9:16',
      imageUrl:
          'https://images.unsplash.com/photo-1550745165-9bc0b252726f?auto=format&fit=crop&w=600&q=80',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  /// Fetch categories from Supabase `categories` table
  Future<List<CategoryModel>> getCategories() async {
    final client = _client;
    if (client == null) {
      return CategoryModel.defaults;
    }

    try {
      final List<dynamic> response = await client
          .from('design_categories')
          .select()
          .order('display_order', ascending: true);

      if (response.isNotEmpty) {
        return response
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      try {
        final List<dynamic> response = await client
            .from('categories')
            .select()
            .order('created_at', ascending: true);

        if (response.isNotEmpty) {
          return response
              .map(
                (item) => CategoryModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching categories: $e');
        }
      }
    }

    return CategoryModel.defaults;
  }

  /// Fetch projects for current user from Supabase `designs` table
  Future<List<ProjectModel>> getUserProjects() async {
    final client = _client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      return List.unmodifiable(_demoProjects);
    }

    try {
      final List<dynamic> response = await client
          .from('designs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response
          .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user projects: $e');
      }
      return List.unmodifiable(_demoProjects);
    }
  }

  /// Get recent projects (up to limit)
  Future<List<ProjectModel>> getRecentProjects({int limit = 5}) async {
    final projects = await getUserProjects();
    if (projects.length <= limit) return projects;
    return projects.sublist(0, limit);
  }

  /// Create a new project in Supabase `designs` table
  Future<ProjectModel?> createProject({
    required String title,
    required String prompt,
    String? style,
    String? aspectRatio,
    String? imageUrl,
    Map<String, dynamic>? documentData,
  }) async {
    final client = _client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      // Create in local demo list
      final newDemo = ProjectModel(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo-user',
        title: title,
        prompt: prompt,
        style: style ?? 'فاخر ذهبي',
        aspectRatio: aspectRatio ?? '1:1',
        imageUrl: imageUrl,
        status: 'draft',
        documentData: documentData,
        createdAt: DateTime.now(),
      );
      _demoProjects.insert(0, newDemo);
      return newDemo;
    }

    try {
      final newRecord = <String, dynamic>{
        'user_id': user.id,
        'title': title.trim(),
        'prompt': prompt.trim(),
        'status': 'draft',
        'style': style ?? 'فاخر ذهبي',
        'aspect_ratio': aspectRatio ?? '1:1',
        'is_public': false,
      };
      if (imageUrl != null) newRecord['image_url'] = imageUrl;

      final response = await client
          .from('designs')
          .insert(newRecord)
          .select()
          .single();

      final created = ProjectModel.fromJson(response);
      return created;
    } catch (e) {
      if (kDebugMode) {
        print('Error inserting project into Supabase: $e');
      }
      // Fallback local insertion if network glitch
      final fallback = ProjectModel(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        userId: user.id,
        title: title,
        prompt: prompt,
        style: style ?? 'فاخر ذهبي',
        aspectRatio: aspectRatio ?? '1:1',
        imageUrl: imageUrl,
        status: 'draft',
        documentData: documentData,
        createdAt: DateTime.now(),
      );
      _demoProjects.insert(0, fallback);
      return fallback;
    }
  }

  /// Update project metadata and structured document data
  Future<bool> updateProject({
    required String id,
    String? title,
    String? prompt,
    Map<String, dynamic>? documentData,
  }) async {
    final client = _client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      final idx = _demoProjects.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _demoProjects[idx] = _demoProjects[idx].copyWith(
          title: title,
          prompt: prompt,
          documentData: documentData,
          updatedAt: DateTime.now(),
        );
      }
      return true;
    }

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (title != null) updates['title'] = title.trim();
      if (prompt != null) updates['prompt'] = prompt.trim();
      if (documentData != null) updates['document_data'] = documentData;

      await client
          .from('designs')
          .update(updates)
          .eq('id', id)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating project in Supabase: $e');
      }
      return false;
    }
  }

  /// Rename a project
  Future<bool> renameProject(String id, String newTitle) async {
    final client = _client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      final idx = _demoProjects.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _demoProjects[idx] = _demoProjects[idx].copyWith(
          title: newTitle.trim(),
        );
      }
      return true;
    }

    try {
      await client
          .from('designs')
          .update({
            'title': newTitle.trim(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error renaming project: $e');
      }
      return false;
    }
  }

  /// Duplicate a project
  Future<ProjectModel?> duplicateProject(String id) async {
    final all = await getUserProjects();
    final target = all.where((p) => p.id == id);
    if (target.isEmpty) return null;

    final orig = target.first;
    return createProject(
      title: 'نسخة من ${orig.title}',
      prompt: orig.prompt,
      style: orig.style,
      aspectRatio: orig.aspectRatio,
      imageUrl: orig.imageUrl,
      documentData: orig.documentData,
    );
  }

  /// Delete a project from Supabase
  Future<bool> deleteProject(String id) async {
    final client = _client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      _demoProjects.removeWhere((p) => p.id == id);
      return true;
    }

    try {
      await client.from('designs').delete().eq('id', id).eq('user_id', user.id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting project: $e');
      }
      return false;
    }
  }

  /// Update project status (e.g. to completed)
  Future<bool> updateProjectStatus(String id, String status) async {
    final client = _client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      final idx = _demoProjects.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _demoProjects[idx] = _demoProjects[idx].copyWith(status: status);
      }
      return true;
    }

    try {
      await client
          .from('designs')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', user.id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating project status: $e');
      }
      return false;
    }
  }
}
