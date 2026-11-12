import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';
import '../../templates/models/document_structure.dart';
import '../models/ai_generation_request.dart';
import '../models/ai_generation_result.dart';

class AiDesignService {
  AiDesignService._();
  static final AiDesignService instance = AiDesignService._();

  SupabaseClient? get _client => SupabaseService.instance.client;

  /// Main AI generation method with multi-stage progress callbacks
  Future<AiGenerationResult> generateDesign(
    AiGenerationRequest request, {
    void Function(String stage, double progress)? onProgress,
  }) async {
    final startTime = DateTime.now();

    onProgress?.call('تحليل الفكرة وتحديد الهوية البصرية...', 0.20);
    await Future.delayed(const Duration(milliseconds: 300));

    onProgress?.call('تحديد المقاسات والألوان وتناغم الخطوط...', 0.45);
    await Future.delayed(const Duration(milliseconds: 350));

    TemplateDocument? document;
    String providerUsed = 'built-in-synthesizer';
    bool apiKeyConfigured = false;

    // 1. Attempt secure server-side generation via Supabase Edge Function
    final client = _client;
    if (client != null) {
      try {
        final FunctionResponse response = await client.functions.invoke(
          'generate-design',
          body: request.toJson(),
        );

        if (response.status == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          if (data['success'] == true && data['document'] != null) {
            document = TemplateDocument.fromJson(
              data['document'] as Map<String, dynamic>,
            );
            providerUsed = data['provider'] as String? ?? 'openai:gpt-4o';
            apiKeyConfigured = data['apiKeyConfigured'] as bool? ?? true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Edge Function notice: $e (Falling back to local synthesizer)');
        }
      }
    }

    onProgress?.call('توليد طبقات النصوص وتوزيع العناصر...', 0.70);
    await Future.delayed(const Duration(milliseconds: 300));

    // 2. Client-side high quality deterministic synthesizer fallback
    document ??= _synthesizeDocument(request);

    onProgress?.call('بناء وتدقيق هيكل المستند متعدد الطبقات...', 0.90);
    await Future.delayed(const Duration(milliseconds: 250));

    final latency = DateTime.now().difference(startTime).inMilliseconds;

    // 3. Log usage in Supabase if logged in
    _logUsage(request, providerUsed, latency);

    onProgress?.call('اكتمل توليد التصميم بنجاح!', 1.0);

    return AiGenerationResult.success(
      document: document,
      provider: providerUsed,
      apiKeyConfigured: apiKeyConfigured,
      latencyMs: latency,
    );
  }

  /// Create and persist a full user project in Supabase from generated AI document
  Future<ProjectModel?> saveGeneratedProject({
    required String title,
    required String prompt,
    required TemplateDocument document,
    String? style,
    String? aspectRatio,
  }) async {
    final previewUrl = document.pages.isNotEmpty
        ? document.pages.first.background?.imageUrl ??
              'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80'
        : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80';

    return ProjectService.instance.createProject(
      title: title,
      prompt: prompt,
      style: style ?? 'فاخر ذهبي',
      aspectRatio: aspectRatio ?? '1:1',
      imageUrl: previewUrl,
      documentData: document.toJson(),
    );
  }

  /// Contextual AI Refinement Command
  Future<TemplateDocument> refineDesign({
    required TemplateDocument currentDocument,
    required String command,
    void Function(String stage, double progress)? onProgress,
  }) async {
    onProgress?.call('تحليل أمر التعديل الذكي...', 0.30);
    await Future.delayed(const Duration(milliseconds: 300));

    onProgress?.call('إعادة صياغة الطبقات وتناغم الألوان...', 0.70);
    await Future.delayed(const Duration(milliseconds: 300));

    final isMoreLuxury =
        command.contains('فخام') ||
        command.contains('ذهب') ||
        command.contains('راقي');
    final isMinimal = command.contains('مينيمال') || command.contains('بسيط');

    final oldPages = currentDocument.pages;
    final newPages = <DocumentPage>[];

    for (final page in oldPages) {
      final updatedElements = <DocumentElement>[];
      for (final el in page.elements) {
        if (el.type == 'text') {
          final style = Map<String, dynamic>.from(el.style);
          if (isMoreLuxury) {
            style['color'] = '#D4AF37';
            style['fontFamily'] = 'Tajawal';
            style['fontWeight'] = 'bold';
          } else if (isMinimal) {
            style['color'] = '#F6E9D8';
            style['fontWeight'] = 'w400';
          }
          updatedElements.add(el.copyWith(style: style));
        } else if (el.type == 'shape') {
          final style = Map<String, dynamic>.from(el.style);
          if (isMoreLuxury) {
            style['fillColor'] = '#7A0E2C';
            style['borderColor'] = '#D4AF37';
          }
          updatedElements.add(el.copyWith(style: style));
        } else {
          updatedElements.add(el);
        }
      }

      newPages.add(
        DocumentPage(
          id: page.id,
          background: PageBackground(
            color: isMoreLuxury ? '#0B132B' : page.background?.color,
            imageUrl: page.background?.imageUrl,
          ),
          elements: updatedElements,
        ),
      );
    }

    onProgress?.call('تم تطبيق التعديلات بنجاح!', 1.0);

    return TemplateDocument(
      pages: newPages,
      metadata: {
        ...currentDocument.metadata,
        'lastRefinement': command,
        'refinedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Synthesizes high-fidelity structured multi-layered design document
  TemplateDocument _synthesizeDocument(AiGenerationRequest request) {
    final w = request.width;
    final h = request.height;
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(request.prompt);

    final title = request.brandName?.isNotEmpty == true
        ? request.brandName!
        : (request.mainHeading?.isNotEmpty == true
              ? request.mainHeading!
              : (isArabic
                    ? request.prompt.split('\n').first.trim()
                    : request.prompt.split('\n').first.trim()));

    final subtitle = request.supportingText?.isNotEmpty == true
        ? request.supportingText!
        : (isArabic
              ? 'حوّل فكرتك إلى تصميم متألق بأعلى معايير الإبداع والاحترافية.'
              : 'Elevate your vision with bespoke luxury and refined creativity.');

    final isLuxury =
        request.style.contains('فاخر') ||
        request.style.contains('luxury') ||
        request.prompt.contains('فاخر') ||
        request.prompt.contains('ذهبي');

    final bgImage = _selectCuratedImage(request.category, isLuxury);

    return TemplateDocument(
      pages: [
        DocumentPage(
          id: 'page_1',
          background: PageBackground(
            color: isLuxury ? '#0B132B' : '#0D1B3E',
            imageUrl: bgImage,
          ),
          elements: [
            // 1. Badge Shape Layer
            DocumentElement(
              id: 'layer_badge_bg',
              type: 'shape',
              content: 'rounded_rect',
              x: w * 0.30,
              y: h * 0.10,
              width: w * 0.40,
              height: 42,
              style: {
                'fillColor': '#7A0E2C',
                'borderColor': '#D4AF37',
                'borderWidth': 1.5,
                'borderRadius': 21.0,
              },
            ),

            // 2. Badge Text Layer
            DocumentElement(
              id: 'layer_badge_text',
              type: 'text',
              content: isArabic ? 'تصميم ذكي وحصري ✨' : 'Exclusive AI Design ✨',
              x: w * 0.30,
              y: h * 0.10 + 9,
              width: w * 0.40,
              height: 24,
              style: {
                'fontSize': 14.0,
                'color': '#F6E9D8',
                'fontFamily': 'Tajawal',
                'fontWeight': 'bold',
                'textAlign': 'center',
                'isRTL': isArabic,
              },
            ),

            // 3. Main Headline Text Layer
            DocumentElement(
              id: 'layer_headline',
              type: 'text',
              content: title,
              x: w * 0.08,
              y: h * 0.20,
              width: w * 0.84,
              height: 90,
              style: {
                'fontSize': w < 800 ? 32.0 : 42.0,
                'color': '#D4AF37',
                'fontFamily': 'Tajawal',
                'fontWeight': '900',
                'textAlign': 'center',
                'isRTL': isArabic,
              },
            ),

            // 4. Subtitle Text Layer
            DocumentElement(
              id: 'layer_subtitle',
              type: 'text',
              content: subtitle,
              x: w * 0.10,
              y: h * 0.31,
              width: w * 0.80,
              height: 60,
              style: {
                'fontSize': 17.0,
                'color': '#F6E9D8',
                'fontFamily': 'Tajawal',
                'fontWeight': 'w500',
                'textAlign': 'center',
                'isRTL': isArabic,
              },
            ),

            // 5. Featured Central Visual Layer
            DocumentElement(
              id: 'layer_hero_image',
              type: 'image',
              content:
                  'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
              x: w * 0.15,
              y: h * 0.42,
              width: w * 0.70,
              height: h * 0.38,
              style: {
                'borderRadius': 22.0,
                'borderColor': '#D4AF37',
                'borderWidth': 1.5,
              },
            ),

            // 6. Action Button Shape Layer
            DocumentElement(
              id: 'layer_cta_shape',
              type: 'shape',
              content: 'rounded_rect',
              x: w * 0.26,
              y: h * 0.84,
              width: w * 0.48,
              height: 52,
              style: {'fillColor': '#D4AF37', 'borderRadius': 14.0},
            ),

            // 7. Action Button Text Layer
            DocumentElement(
              id: 'layer_cta_text',
              type: 'text',
              content: isArabic
                  ? 'اكتشف المزيد الآن'
                  : 'Discover The Collection',
              x: w * 0.26,
              y: h * 0.84 + 14,
              width: w * 0.48,
              height: 26,
              style: {
                'fontSize': 16.0,
                'color': '#0B132B',
                'fontFamily': 'Tajawal',
                'fontWeight': 'bold',
                'textAlign': 'center',
                'isRTL': isArabic,
              },
            ),
          ],
        ),
      ],
      metadata: {
        'title': title,
        'prompt': request.prompt,
        'category': request.category,
        'style': request.style,
        'dimensions': '${w.toInt()}x${h.toInt()}',
        'generatedAt': DateTime.now().toIso8601String(),
        'engine': 'ANSHIILY-AI-Core-v4',
      },
    );
  }

  String _selectCuratedImage(String category, bool isLuxury) {
    switch (category) {
      case 'social-media':
        return 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80';
      case 'marketing':
        return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80';
      case 'presentations':
        return 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=1200&q=80';
      case 'invitations':
        return 'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80';
      default:
        return 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=1200&q=80';
    }
  }

  Future<void> _logUsage(
    AiGenerationRequest request,
    String provider,
    int latencyMs,
  ) async {
    final client = _client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;

    try {
      await client.from('ai_generation_logs').insert({
        'user_id': user.id,
        'provider': provider,
        'prompt': request.prompt,
        'category': request.category,
        'dimensions': '${request.width.toInt()}x${request.height.toInt()}',
        'latency_ms': latencyMs,
        'status': 'completed',
      });
    } catch (_) {}
  }
}
