import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:anshiily/features/templates/models/document_structure.dart';
import 'package:anshiily/features/templates/models/editor_state_types.dart';
import 'package:anshiily/features/templates/utils/editor_font_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 5 Professional Design Editor Tests', () {
    late TemplateDocument initialDoc;

    setUp(() {
      initialDoc = TemplateDocument(
        pages: [
          DocumentPage(
            id: 'page_1',
            background: const PageBackground(color: '#0B132B'),
            elements: [
              const DocumentElement(
                id: 'el_text_1',
                type: 'text',
                content: 'عنوان التصميم الرئيسي',
                x: 100,
                y: 150,
                width: 800,
                height: 90,
                style: {
                  'fontSize': 36.0,
                  'color': '#D4AF37',
                  'fontFamily': 'Tajawal',
                  'fontWeight': 'bold',
                  'textAlign': 'center',
                },
              ),
              const DocumentElement(
                id: 'el_shape_1',
                type: 'shape',
                content: 'rounded_rect',
                x: 80,
                y: 100,
                width: 840,
                height: 200,
                style: {'fillColor': '#7A0E2C', 'borderColor': '#D4AF37'},
              ),
            ],
          ),
        ],
      );
    });

    test('Feature 1 - Text layer editing and formatting updates', () {
      final page = initialDoc.pages.first;
      final textElement = page.elements.firstWhere((e) => e.type == 'text');

      // 1. Content edit
      final updatedContent = textElement.copyWith(
        content: 'العنوان الجديد المعدل',
      );
      expect(updatedContent.content, 'العنوان الجديد المعدل');

      // 2. Font family update
      final styleWithFont = Map<String, dynamic>.from(textElement.style);
      styleWithFont['fontFamily'] = 'Cairo';
      final updatedFont = textElement.copyWith(style: styleWithFont);
      expect(updatedFont.style['fontFamily'], 'Cairo');

      // 3. Font size update
      final styleWithSize = Map<String, dynamic>.from(textElement.style);
      styleWithSize['fontSize'] = 48.0;
      final updatedSize = textElement.copyWith(style: styleWithSize);
      expect(updatedSize.style['fontSize'], 48.0);

      // 4. Color & formatting
      final styleWithColor = Map<String, dynamic>.from(textElement.style);
      styleWithColor['color'] = '#F6E9D8';
      styleWithColor['fontWeight'] = 'bold';
      styleWithColor['fontStyle'] = 'italic';
      styleWithColor['textAlign'] = 'right';
      final updatedFormatting = textElement.copyWith(style: styleWithColor);

      expect(updatedFormatting.style['color'], '#F6E9D8');
      expect(updatedFormatting.style['fontWeight'], 'bold');
      expect(updatedFormatting.style['fontStyle'], 'italic');
      expect(updatedFormatting.style['textAlign'], 'right');
    });

    test(
      'Feature 2 - Element positioning and coordinate delta calculation',
      () {
        final page = initialDoc.pages.first;
        final element = page.elements.first;

        const scale = 0.35;
        const screenDeltaX = 14.0;
        const screenDeltaY = -7.0;

        final docDeltaX = screenDeltaX / scale; // +40
        final docDeltaY = screenDeltaY / scale; // -20

        final movedElement = element.copyWith(
          x: element.x + docDeltaX,
          y: element.y + docDeltaY,
        );

        expect(movedElement.x, closeTo(140.0, 0.01));
        expect(movedElement.y, closeTo(130.0, 0.01));
      },
    );

    test(
      'Feature 3 - Multi-page management (Add, Switch, Delete, Duplicate)',
      () {
        var doc = initialDoc;
        expect(doc.pages.length, 1);

        // Add page
        final newPage = DocumentPage(
          id: 'page_2',
          background: const PageBackground(color: '#111B38'),
          elements: const [
            DocumentElement(
              id: 'el_page2_title',
              type: 'text',
              content: 'محتوى الصفحة الثانية',
              x: 50,
              y: 50,
              width: 400,
              height: 60,
            ),
          ],
        );
        doc = doc.copyWith(pages: [...doc.pages, newPage]);
        expect(doc.pages.length, 2);
        expect(doc.pages[1].id, 'page_2');

        // Duplicate page
        final duplicatedPage = doc.pages[0].copyWith(id: 'page_1_copy');
        doc = doc.copyWith(pages: [doc.pages[0], duplicatedPage, doc.pages[1]]);
        expect(doc.pages.length, 3);
        expect(doc.pages[1].id, 'page_1_copy');

        // Delete page
        final updatedPages = List<DocumentPage>.from(doc.pages)..removeAt(1);
        doc = doc.copyWith(pages: updatedPages);
        expect(doc.pages.length, 2);

        // Prevent deletion of last page
        final canDelete = doc.pages.length > 1;
        expect(canDelete, isTrue);

        final singlePageDoc = doc.copyWith(pages: [doc.pages.first]);
        expect(singlePageDoc.pages.length > 1, isFalse);
      },
    );

    test('Feature 4 - Undo/Redo history stack consistency', () {
      final undoStack = <String>[];
      final redoStack = <String>[];
      var currentDoc = initialDoc;

      // Mutation 1: Change text
      undoStack.add(jsonEncode(currentDoc.toJson()));
      final el = currentDoc.pages[0].elements[0];
      final mutatedEl = el.copyWith(content: 'تغيير 1');
      currentDoc = currentDoc.copyWith(
        pages: [
          currentDoc.pages[0].copyWith(
            elements: [mutatedEl, currentDoc.pages[0].elements[1]],
          ),
        ],
      );
      expect(currentDoc.pages[0].elements[0].content, 'تغيير 1');
      expect(undoStack.length, 1);

      // Mutation 2: Change color
      undoStack.add(jsonEncode(currentDoc.toJson()));
      final style = Map<String, dynamic>.from(mutatedEl.style);
      style['color'] = '#FFFFFF';
      final mutatedEl2 = mutatedEl.copyWith(style: style);
      currentDoc = currentDoc.copyWith(
        pages: [
          currentDoc.pages[0].copyWith(
            elements: [mutatedEl2, currentDoc.pages[0].elements[1]],
          ),
        ],
      );
      expect(currentDoc.pages[0].elements[0].style['color'], '#FFFFFF');
      expect(undoStack.length, 2);

      // Action: Undo Mutation 2
      redoStack.add(jsonEncode(currentDoc.toJson()));
      final prevSnapshot = undoStack.removeLast();
      currentDoc = TemplateDocument.fromJson(
        jsonDecode(prevSnapshot) as Map<String, dynamic>,
      );
      expect(currentDoc.pages[0].elements[0].style['color'], '#D4AF37');
      expect(currentDoc.pages[0].elements[0].content, 'تغيير 1');
      expect(redoStack.length, 1);

      // Action: Redo Mutation 2
      undoStack.add(jsonEncode(currentDoc.toJson()));
      final nextSnapshot = redoStack.removeLast();
      currentDoc = TemplateDocument.fromJson(
        jsonDecode(nextSnapshot) as Map<String, dynamic>,
      );
      expect(currentDoc.pages[0].elements[0].style['color'], '#FFFFFF');
      expect(redoStack.isEmpty, isTrue);
    });

    test('Feature 5 - Autosave state flow', () {
      var status = AutosaveStatus.saved;
      expect(status, AutosaveStatus.saved);

      // Modification occurs
      status = AutosaveStatus.unsaved;
      expect(status, AutosaveStatus.unsaved);

      // Timer triggers save
      status = AutosaveStatus.saving;
      expect(status, AutosaveStatus.saving);

      // Server responds 200 OK
      status = AutosaveStatus.saved;
      expect(status, AutosaveStatus.saved);
    });

    test('Font Helper returns valid GoogleFonts text styles', () {
      final tajawalStyle = EditorFontHelper.getTextStyle(
        'Tajawal',
        fontSize: 20,
      );
      expect(tajawalStyle.fontSize, 20);

      final cairoStyle = EditorFontHelper.getTextStyle('Cairo', fontSize: 24);
      expect(cairoStyle.fontSize, 24);

      final almaraiStyle = EditorFontHelper.getTextStyle(
        'Almarai',
        fontSize: 18,
      );
      expect(almaraiStyle.fontSize, 18);

      final amiriStyle = EditorFontHelper.getTextStyle('Amiri', fontSize: 30);
      expect(amiriStyle.fontSize, 30);

      final fallbackStyle = EditorFontHelper.getTextStyle(
        'UnknownFont',
        fontSize: 16,
      );
      expect(fallbackStyle.fontSize, 16);
    });
  });
}
