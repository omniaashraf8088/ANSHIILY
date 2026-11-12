import 'package:flutter_test/flutter_test.dart';
import 'package:anshiily/features/ai_engine/models/ai_generation_request.dart';
import 'package:anshiily/features/ai_engine/services/ai_design_service.dart';
import 'package:anshiily/features/templates/models/document_structure.dart';

void main() {
  group('Phase 4: AI Design Generation Engine Tests', () {
    test('AI Prompt and Request Construction with all parameters', () {
      const request = AiGenerationRequest(
        prompt: 'صمم إعلاناً فاخراً لمنتج عناية بالبشرة بالذهبي والعاجي',
        category: 'social-media',
        style: 'فاخر ذهبي (Luxury Gold)',
        aspectRatio: 'Instagram Post 1:1',
        width: 1080,
        height: 1080,
        brandName: 'Royal Glow',
        mainHeading: 'أسرار النضارة الملكية',
        supportingText: 'تركيبة ذهبية فريدة من أنقى المكونات الطبيعية',
        targetAudience: 'عشاق العناية الفاخرة',
      );

      expect(request.prompt.isNotEmpty, isTrue);
      expect(request.width, equals(1080));
      expect(request.height, equals(1080));
      expect(request.brandName, equals('Royal Glow'));

      final json = request.toJson();
      expect(json['category'], equals('social-media'));
      expect(json['brandName'], equals('Royal Glow'));
      expect(json['width'], equals(1080));
    });

    test(
      'AI Engine Generates Valid Multi-Layered Structured Document',
      () async {
        const request = AiGenerationRequest(
          prompt: 'إعلان فاخر لمنتج عطور شرقية',
          category: 'marketing',
          style: 'luxury',
          width: 1200,
          height: 628,
          brandName: 'عود السلطان',
        );

        final result = await AiDesignService.instance.generateDesign(request);

        expect(result.isSuccess, isTrue);
        expect(result.document, isNotNull);

        final doc = result.document!;
        expect(doc.pages.isNotEmpty, isTrue);

        final firstPage = doc.pages.first;
        expect(firstPage.background, isNotNull);
        expect(firstPage.background!.imageUrl, isNotNull);

        // Verify layers exist: text, shapes, imagery
        final elements = firstPage.elements;
        expect(elements.length, greaterThanOrEqualTo(5));

        final textElements = elements.where((e) => e.type == 'text').toList();
        final shapeElements = elements.where((e) => e.type == 'shape').toList();
        final imageElements = elements.where((e) => e.type == 'image').toList();

        expect(textElements.isNotEmpty, isTrue);
        expect(shapeElements.isNotEmpty, isTrue);
        expect(imageElements.isNotEmpty, isTrue);

        // Verify Arabic RTL support in text layer
        final headline = textElements.firstWhere(
          (e) => e.id.contains('headline'),
        );
        expect(headline.style['isRTL'], isTrue);
        expect(headline.style['fontFamily'], equals('Tajawal'));
        expect(headline.content.contains('عود السلطان'), isTrue);
      },
    );

    test(
      'AI Design Refinement Contextual Command Updates Styles Cleanly',
      () async {
        const request = AiGenerationRequest(
          prompt: 'تصميم بطاقة دعوة لمؤتمر أعمال',
          category: 'business-documents',
          style: 'minimal',
          width: 1080,
          height: 1080,
        );

        final initial = await AiDesignService.instance.generateDesign(request);
        expect(initial.isSuccess, isTrue);

        final refinedDoc = await AiDesignService.instance.refineDesign(
          currentDocument: initial.document!,
          command: 'اجعل التصميم أكثر فخامة باللون الذهبي والكحلي',
        );

        expect(refinedDoc.pages.isNotEmpty, isTrue);
        expect(refinedDoc.metadata['lastRefinement'], isNotNull);

        // Verify colors and styles were refined
        final headline = refinedDoc.pages.first.elements.firstWhere(
          (e) => e.type == 'text' && e.id.contains('headline'),
        );
        expect(headline.style['color'], equals('#D4AF37'));
      },
    );

    test(
      'Structured Document JSON Round-Trip Serialization for Supabase JSONB',
      () {
        const doc = TemplateDocument(
          pages: [
            DocumentPage(
              id: 'page_1',
              background: PageBackground(color: '#0B132B'),
              elements: [
                DocumentElement(
                  id: 'el_text_1',
                  type: 'text',
                  content: 'نص تجريبي للتحقق من Supabase',
                  x: 100,
                  y: 150,
                  width: 800,
                  height: 120,
                  style: {
                    'fontSize': 28,
                    'color': '#D4AF37',
                    'fontFamily': 'Tajawal',
                    'isRTL': true,
                  },
                ),
              ],
            ),
          ],
          metadata: {'version': '4.0', 'engine': 'ANSHIILY-AI'},
        );

        final map = doc.toJson();
        final restored = TemplateDocument.fromJson(map);

        expect(restored.pages.length, equals(1));
        expect(
          restored.pages.first.elements.first.content,
          equals('نص تجريبي للتحقق من Supabase'),
        );
        expect(restored.metadata['version'], equals('4.0'));
      },
    );
  });
}
