import 'package:flutter_test/flutter_test.dart';
import 'package:anshiily/features/projects/models/category_model.dart';
import 'package:anshiily/features/templates/models/template_model.dart';
import 'package:anshiily/features/templates/models/document_structure.dart';

void main() {
  group('Phase 3 Models and Structures Tests', () {
    test('Default 10 categories are properly defined and non-empty', () {
      final categories = CategoryModel.defaults;
      expect(categories.length, equals(10));
      for (final cat in categories) {
        expect(cat.nameAr.isNotEmpty, isTrue);
        expect(cat.nameEn.isNotEmpty, isTrue);
        expect(cat.slug.isNotEmpty, isTrue);
        expect(cat.descriptionAr?.isNotEmpty ?? false, isTrue);
      }
    });

    test('Default templates contain structured editable document data', () {
      final templates = TemplateModel.defaults;
      expect(templates.length, greaterThanOrEqualTo(6));
      for (final tpl in templates) {
        expect(tpl.nameAr.isNotEmpty, isTrue);
        expect(tpl.categorySlug.isNotEmpty, isTrue);
        expect(tpl.documentData, isNotNull);
        final doc = tpl.documentData;
        expect(doc.pages.isNotEmpty, isTrue);
        expect(doc.pages.first.elements.isNotEmpty, isTrue);
        final restored = TemplateDocument.fromJson(doc.toJson());
        expect(restored.pages.length, equals(doc.pages.length));
      }
    });

    test('DocumentStructure JSON round-trip serialization', () {
      const element = DocumentElement(
        id: 'el-1',
        type: 'text',
        content: 'عنوان تجريبي',
        x: 50,
        y: 100,
        width: 300,
        height: 80,
        style: {
          'fontSize': 24,
          'color': '#D4AF37',
          'fontFamily': 'Tajawal',
          'fontWeight': 'bold',
        },
      );

      final map = element.toJson();
      final restored = DocumentElement.fromJson(map);

      expect(restored.id, equals('el-1'));
      expect(restored.type, equals('text'));
      expect(restored.content, equals('عنوان تجريبي'));
      expect(restored.style['fontSize'], equals(24));
      expect(restored.style['color'], equals('#D4AF37'));
    });
  });
}
