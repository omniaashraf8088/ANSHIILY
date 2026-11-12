import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../ai_engine/services/ai_design_service.dart';
import '../../projects/models/project_model.dart';
import '../../projects/services/project_service.dart';
import '../models/document_structure.dart';
import '../models/editor_state_types.dart';
import '../models/template_model.dart';
import '../utils/editor_font_helper.dart';
import '../widgets/editor_toolbar.dart';
import '../widgets/generic_properties_sheet.dart';
import '../widgets/page_manager_bar.dart';
import '../widgets/text_properties_sheet.dart';
import '../../export/widgets/export_modal_sheet.dart';

class ProjectEditorScreen extends StatefulWidget {
  final ProjectModel project;
  final TemplateModel? template;
  final TemplateDocument? initialDocument;

  const ProjectEditorScreen({
    super.key,
    required this.project,
    this.template,
    this.initialDocument,
  });

  @override
  State<ProjectEditorScreen> createState() => _ProjectEditorScreenState();
}

class _ProjectEditorScreenState extends State<ProjectEditorScreen> {
  late TemplateDocument _document;
  int _selectedPageIndex = 0;
  String? _selectedElementId;

  // History system (Undo / Redo)
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];
  static const int _maxHistoryDepth = 30;

  // Autosave system
  Timer? _autosaveTimer;
  AutosaveStatus _autosaveStatus = AutosaveStatus.saved;

  // AI Refinement states
  bool _isRefining = false;
  String _refinementStage = '';

  @override
  void initState() {
    super.initState();
    _initDocument();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }

  void _initDocument() {
    if (widget.initialDocument != null) {
      _document = widget.initialDocument!;
    } else if (widget.project.documentData != null &&
        widget.project.documentData!.isNotEmpty) {
      _document = TemplateDocument.fromJson(widget.project.documentData!);
    } else if (widget.template != null) {
      _document = widget.template!.documentData;
    } else {
      _document = _buildDefaultFallbackDoc();
    }

    // Ensure at least 1 page exists
    if (_document.pages.isEmpty) {
      _document = _buildDefaultFallbackDoc();
    }
  }

  TemplateDocument _buildDefaultFallbackDoc() {
    return TemplateDocument(
      pages: [
        DocumentPage(
          id: 'page_1',
          background: const PageBackground(
            color: '#0B132B',
            imageUrl:
                'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
          ),
          elements: [
            DocumentElement(
              id: 'el_title',
              type: 'text',
              content: widget.project.title.isNotEmpty
                  ? widget.project.title
                  : 'تصميم أنشئلي الفاخر',
              x: 80,
              y: 160,
              width: 920,
              height: 100,
              style: const {
                'fontSize': 42.0,
                'color': '#D4AF37',
                'fontFamily': 'Tajawal',
                'fontWeight': 'bold',
                'textAlign': 'center',
                'isRTL': true,
              },
            ),
            const DocumentElement(
              id: 'el_subtitle',
              type: 'text',
              content: 'من فكرة إلى تصميم احترافي متكامل',
              x: 120,
              y: 280,
              width: 840,
              height: 60,
              style: {
                'fontSize': 24.0,
                'color': '#F6E9D8',
                'fontFamily': 'Tajawal',
                'fontWeight': '500',
                'textAlign': 'center',
                'isRTL': true,
              },
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // HISTORY (UNDO / REDO) SYSTEM
  // ===========================================================================

  void _recordHistory({bool clearRedo = true}) {
    final snapshot = jsonEncode(_document.toJson());
    _undoStack.add(snapshot);
    if (_undoStack.length > _maxHistoryDepth) {
      _undoStack.removeAt(0);
    }
    if (clearRedo) {
      _redoStack.clear();
    }
    _markUnsaved();
  }

  void _undo() {
    if (_undoStack.isEmpty) return;

    final currentSnapshot = jsonEncode(_document.toJson());
    _redoStack.add(currentSnapshot);

    final previousSnapshot = _undoStack.removeLast();
    final restoredDoc = TemplateDocument.fromJson(
      jsonDecode(previousSnapshot) as Map<String, dynamic>,
    );

    setState(() {
      _document = restoredDoc;
      if (_selectedPageIndex >= _document.pages.length) {
        _selectedPageIndex = max(0, _document.pages.length - 1);
      }
      _validateSelection();
    });

    _scheduleAutosave();
  }

  void _redo() {
    if (_redoStack.isEmpty) return;

    final currentSnapshot = jsonEncode(_document.toJson());
    _undoStack.add(currentSnapshot);

    final nextSnapshot = _redoStack.removeLast();
    final restoredDoc = TemplateDocument.fromJson(
      jsonDecode(nextSnapshot) as Map<String, dynamic>,
    );

    setState(() {
      _document = restoredDoc;
      if (_selectedPageIndex >= _document.pages.length) {
        _selectedPageIndex = max(0, _document.pages.length - 1);
      }
      _validateSelection();
    });

    _scheduleAutosave();
  }

  void _validateSelection() {
    if (_selectedElementId == null) return;
    final currPage = _getCurrentPage();
    if (currPage == null ||
        !currPage.elements.any((e) => e.id == _selectedElementId)) {
      _selectedElementId = null;
    }
  }

  DocumentPage? _getCurrentPage() {
    if (_document.pages.isEmpty) return null;
    if (_selectedPageIndex >= _document.pages.length) {
      _selectedPageIndex = _document.pages.length - 1;
    }
    return _document.pages[_selectedPageIndex];
  }

  DocumentElement? _getSelectedElement() {
    final page = _getCurrentPage();
    if (page == null || _selectedElementId == null) return null;
    try {
      return page.elements.firstWhere((e) => e.id == _selectedElementId);
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // AUTOSAVE & PERSISTENCE
  // ===========================================================================

  void _markUnsaved() {
    if (_autosaveStatus != AutosaveStatus.unsaved &&
        _autosaveStatus != AutosaveStatus.saving) {
      setState(() => _autosaveStatus = AutosaveStatus.unsaved);
    }
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(const Duration(seconds: 2), () {
      _executeAutosave();
    });
  }

  Future<bool> _executeAutosave() async {
    if (!mounted) return false;

    setState(() => _autosaveStatus = AutosaveStatus.saving);

    try {
      final success = await ProjectService.instance.updateProject(
        id: widget.project.id,
        title: widget.project.title,
        prompt: widget.project.prompt,
        documentData: _document.toJson(),
      );

      if (!mounted) return success;

      setState(() {
        _autosaveStatus = success ? AutosaveStatus.saved : AutosaveStatus.error;
      });
      return success;
    } catch (e) {
      if (mounted) {
        setState(() => _autosaveStatus = AutosaveStatus.error);
      }
      return false;
    }
  }

  Future<void> _handleManualSave() async {
    _autosaveTimer?.cancel();
    final success = await _executeAutosave();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'تم حفظ التعديلات وهيكل المستند في Supabase بنجاح! ☁️'
              : 'فشل الحفظ في السحابة. تحقق من الاتصال.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
        ),
        backgroundColor: success ? AppColors.champagneGold : Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ===========================================================================
  // ELEMENT POSITIONING (DRAG & DROP)
  // ===========================================================================

  void _moveElement(String elementId, double docDeltaX, double docDeltaY) {
    final page = _getCurrentPage();
    if (page == null) return;

    final elements = List<DocumentElement>.from(page.elements);
    final idx = elements.indexWhere((e) => e.id == elementId);
    if (idx == -1) return;

    final old = elements[idx];
    // Clamp to canvas boundaries so element doesn't get lost
    final newX = (old.x + docDeltaX).clamp(-200.0, 1200.0);
    final newY = (old.y + docDeltaY).clamp(-200.0, 1200.0);

    elements[idx] = old.copyWith(x: newX, y: newY);

    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
    });
  }

  // ===========================================================================
  // TEXT & ELEMENT PROPERTY UPDATES
  // ===========================================================================

  void _updateElement(
    String elementId,
    DocumentElement Function(DocumentElement) transform,
  ) {
    final page = _getCurrentPage();
    if (page == null) return;

    final elements = List<DocumentElement>.from(page.elements);
    final idx = elements.indexWhere((e) => e.id == elementId);
    if (idx == -1) return;

    _recordHistory();

    elements[idx] = transform(elements[idx]);

    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
    });

    _scheduleAutosave();
  }

  void _updateTextContent(String newContent) {
    if (_selectedElementId == null) return;
    _updateElement(
      _selectedElementId!,
      (el) => el.copyWith(content: newContent),
    );
  }

  void _updateFontFamily(String family) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) {
      final newStyle = Map<String, dynamic>.from(el.style);
      newStyle['fontFamily'] = family;
      return el.copyWith(style: newStyle);
    });
  }

  void _updateFontSize(double size) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) {
      final newStyle = Map<String, dynamic>.from(el.style);
      newStyle['fontSize'] = size;
      return el.copyWith(style: newStyle);
    });
  }

  void _updateTextColor(String colorHex) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) {
      final newStyle = Map<String, dynamic>.from(el.style);
      newStyle['color'] = colorHex;
      return el.copyWith(style: newStyle);
    });
  }

  void _updateTextBold(bool isBold) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) {
      final newStyle = Map<String, dynamic>.from(el.style);
      newStyle['fontWeight'] = isBold ? 'bold' : 'normal';
      return el.copyWith(style: newStyle);
    });
  }

  void _updateTextItalic(bool isItalic) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) {
      final newStyle = Map<String, dynamic>.from(el.style);
      newStyle['fontStyle'] = isItalic ? 'italic' : 'normal';
      return el.copyWith(style: newStyle);
    });
  }

  void _updateTextAlignment(String alignment) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) {
      final newStyle = Map<String, dynamic>.from(el.style);
      newStyle['textAlign'] = alignment;
      return el.copyWith(style: newStyle);
    });
  }

  void _updateShapeColor(String hex) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) {
      final newStyle = Map<String, dynamic>.from(el.style);
      newStyle['fillColor'] = hex;
      return el.copyWith(style: newStyle);
    });
  }

  void _updateElementOpacity(double opacity) {
    if (_selectedElementId == null) return;
    _updateElement(_selectedElementId!, (el) => el.copyWith(opacity: opacity));
  }

  void _duplicateElement(String elementId) {
    final page = _getCurrentPage();
    if (page == null) return;

    final idx = page.elements.indexWhere((e) => e.id == elementId);
    if (idx == -1) return;

    _recordHistory();

    final target = page.elements[idx];
    final newId =
        'el_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final duplicated = target.copyWith(
      id: newId,
      x: target.x + 30,
      y: target.y + 30,
    );

    final elements = List<DocumentElement>.from(page.elements)..add(duplicated);
    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
      _selectedElementId = newId;
    });

    _scheduleAutosave();
  }

  void _deleteElement(String elementId) {
    final page = _getCurrentPage();
    if (page == null) return;

    _recordHistory();

    final elements = List<DocumentElement>.from(page.elements)
      ..removeWhere((e) => e.id == elementId);

    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
      if (_selectedElementId == elementId) {
        _selectedElementId = null;
      }
    });

    _scheduleAutosave();
  }

  void _bringToFront(String elementId) {
    final page = _getCurrentPage();
    if (page == null) return;

    final idx = page.elements.indexWhere((e) => e.id == elementId);
    if (idx == -1 || idx == page.elements.length - 1) return;

    _recordHistory();

    final elements = List<DocumentElement>.from(page.elements);
    final el = elements.removeAt(idx);
    elements.add(el);

    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
    });

    _scheduleAutosave();
  }

  void _sendToBack(String elementId) {
    final page = _getCurrentPage();
    if (page == null) return;

    final idx = page.elements.indexWhere((e) => e.id == elementId);
    if (idx == -1 || idx == 0) return;

    _recordHistory();

    final elements = List<DocumentElement>.from(page.elements);
    final el = elements.removeAt(idx);
    elements.insert(0, el);

    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
    });

    _scheduleAutosave();
  }

  // ===========================================================================
  // ADD NEW ELEMENTS (TEXT / SHAPES)
  // ===========================================================================

  void _addNewTextElement() {
    final page = _getCurrentPage();
    if (page == null) return;

    _recordHistory();

    final newId = 'text_${DateTime.now().millisecondsSinceEpoch}';
    final newElement = DocumentElement(
      id: newId,
      type: 'text',
      content: 'نص إبداعي جديد',
      x: 200,
      y: 400,
      width: 680,
      height: 80,
      style: const {
        'fontSize': 32.0,
        'color': '#D4AF37',
        'fontFamily': 'Tajawal',
        'fontWeight': 'bold',
        'textAlign': 'center',
        'isRTL': true,
      },
    );

    final elements = List<DocumentElement>.from(page.elements)..add(newElement);
    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
      _selectedElementId = newId;
    });

    _scheduleAutosave();
  }

  void _addNewShapeElement() {
    final page = _getCurrentPage();
    if (page == null) return;

    _recordHistory();

    final newId = 'shape_${DateTime.now().millisecondsSinceEpoch}';
    final newElement = DocumentElement(
      id: newId,
      type: 'shape',
      content: 'rounded_rect',
      x: 180,
      y: 350,
      width: 720,
      height: 200,
      style: const {
        'fillColor': '#7A0E2C',
        'borderColor': '#D4AF37',
        'borderRadius': 16.0,
        'borderWidth': 1.5,
      },
    );

    final elements = List<DocumentElement>.from(page.elements)
      ..insert(0, newElement);
    final updatedPages = List<DocumentPage>.from(_document.pages);
    updatedPages[_selectedPageIndex] = page.copyWith(elements: elements);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
      _selectedElementId = newId;
    });

    _scheduleAutosave();
  }

  // ===========================================================================
  // PAGE MANAGEMENT (MULTI-PAGE)
  // ===========================================================================

  void _addNewPage() {
    _recordHistory();

    final newPageId = 'page_${DateTime.now().millisecondsSinceEpoch}';
    final newPage = DocumentPage(
      id: newPageId,
      background: const PageBackground(color: '#0B132B'),
      elements: [
        DocumentElement(
          id: 'title_${DateTime.now().millisecondsSinceEpoch}',
          type: 'text',
          content: 'عنوان الصفحة ${_document.pages.length + 1}',
          x: 100,
          y: 200,
          width: 880,
          height: 90,
          style: const {
            'fontSize': 38.0,
            'color': '#D4AF37',
            'fontFamily': 'Tajawal',
            'fontWeight': 'bold',
            'textAlign': 'center',
            'isRTL': true,
          },
        ),
      ],
    );

    final updatedPages = List<DocumentPage>.from(_document.pages)..add(newPage);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
      _selectedPageIndex = updatedPages.length - 1;
      _selectedElementId = null;
    });

    _scheduleAutosave();
  }

  void _duplicateCurrentPage() {
    final page = _getCurrentPage();
    if (page == null) return;

    _recordHistory();

    final newPageId = 'page_${DateTime.now().millisecondsSinceEpoch}';
    final duplicatedElements = page.elements.map((el) {
      final newElId =
          'el_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
      return el.copyWith(id: newElId);
    }).toList();

    final newPage = page.copyWith(id: newPageId, elements: duplicatedElements);

    final updatedPages = List<DocumentPage>.from(_document.pages);
    final insertIdx = _selectedPageIndex + 1;
    updatedPages.insert(insertIdx, newPage);

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
      _selectedPageIndex = insertIdx;
      _selectedElementId = null;
    });

    _scheduleAutosave();
  }

  void _confirmDeleteCurrentPage() {
    if (_document.pages.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكن حذف الصفحة الوحيدة في التصميم! ⚠️',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.champagneGold, width: 1.2),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'تأكيد حذف الصفحة',
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف الصفحة ${_selectedPageIndex + 1}؟ ستفقد جميع العناصر الموجودة داخل هذه الصفحة.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(color: AppColors.warmIvory, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCurrentPage();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'حذف الصفحة',
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteCurrentPage() {
    if (_document.pages.length <= 1) return;

    _recordHistory();

    final updatedPages = List<DocumentPage>.from(_document.pages)
      ..removeAt(_selectedPageIndex);

    final newIndex = max(0, min(_selectedPageIndex, updatedPages.length - 1));

    setState(() {
      _document = _document.copyWith(pages: updatedPages);
      _selectedPageIndex = newIndex;
      _selectedElementId = null;
    });

    _scheduleAutosave();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حذف الصفحة بنجاح! 🗑️',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(),
        ),
        backgroundColor: AppColors.champagneGold,
      ),
    );
  }

  // ===========================================================================
  // AI REFINEMENT INTEGRATION
  // ===========================================================================

  void _showAiRefinementModal() {
    final controller = TextEditingController();

    final suggestions = [
      'اجعل التصميم أكثر فخامة باللون الذهبي',
      'غيّر الطابع إلى عصري مينيمال هادئ',
      'اجعل العنوان الرئيسي أكبر حجماً وأكثر بروزاً',
      'استبدل الخلفية بتدرج كحلي ملكي عميق',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0F1B35),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: AppColors.champagneGold, width: 1.5),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.champagneGold,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تعديل التصميم بالذكاء الاصطناعي ✨',
                          style: GoogleFonts.tajawal(
                            color: AppColors.champagneGold,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.champagneGold,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'اكتب توجيهاً ذكياً لتحسين التكوين، الخطوط، الألوان، أو درجات الفخامة.',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    textDirection: TextDirection.rtl,
                    style: GoogleFonts.tajawal(color: AppColors.warmIvory),
                    decoration: InputDecoration(
                      hintText:
                          'مثال: اجعل الألوان أكثر دفئاً وأضف لمسات ذهبية...',
                      hintStyle: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.4),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.map((sug) {
                    return ActionChip(
                      backgroundColor: AppColors.surfaceNavy,
                      side: BorderSide(
                        color: AppColors.champagneGold.withValues(alpha: 0.25),
                      ),
                      label: Text(
                        sug,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory.withValues(alpha: 0.85),
                          fontSize: 11,
                        ),
                      ),
                      onPressed: () {
                        controller.text = sug;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final cmd = controller.text.trim();
                    if (cmd.isEmpty) return;

                    Navigator.pop(ctx);
                    _executeRefinement(cmd);
                  },
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    'تطبيق التعديل الذكي الآن ✨',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: AppColors.deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _executeRefinement(String command) async {
    _recordHistory();

    setState(() {
      _isRefining = true;
      _refinementStage = 'تحليل أمر التعديل الذكي...';
    });

    try {
      final refinedDoc = await AiDesignService.instance.refineDesign(
        currentDocument: _document,
        command: command,
        onProgress: (stage, progress) {
          if (mounted) setState(() => _refinementStage = stage);
        },
      );

      if (!mounted) return;
      setState(() {
        _document = refinedDoc;
        _isRefining = false;
        _selectedElementId = null;
      });

      _scheduleAutosave();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تطبيق التعديل الذكي بنجاح! ✨',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppColors.champagneGold,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRefining = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء التعديل: $e')));
    }
  }

  Future<void> _navigateHome() async {
    if (_autosaveStatus == AutosaveStatus.unsaved) {
      await _executeAutosave();
    }
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  void _showExportModal() {
    ExportModalSheet.show(
      context,
      document: _document,
      projectTitle: widget.project.title,
      projectId: widget.project.id,
      currentPageIndex: _selectedPageIndex,
    );
  }

  // ===========================================================================
  // BUILD METHOD & SCAFFOLD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final currPage = _getCurrentPage();
    final selectedElement = _getSelectedElement();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (_autosaveStatus == AutosaveStatus.unsaved) {
          _executeAutosave();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.deepNavy,
        appBar: EditorToolbar(
          title: widget.project.title,
          autosaveStatus: _autosaveStatus,
          canUndo: _undoStack.isNotEmpty,
          canRedo: _redoStack.isNotEmpty,
          onUndo: _undo,
          onRedo: _redo,
          onAiRefine: _showAiRefinementModal,
          onManualSave: _handleManualSave,
          onExport: _showExportModal,
          onBack: _navigateHome,
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
              // 1. Page Manager Bar (Page switching, add, duplicate, delete)
              PageManagerBar(
                pages: _document.pages,
                currentPageIndex: _selectedPageIndex,
                onSelectPage: (idx) {
                  setState(() {
                    _selectedPageIndex = idx;
                    _selectedElementId = null;
                  });
                },
                onAddPage: _addNewPage,
                onDuplicatePage: _duplicateCurrentPage,
                onDeletePage: _confirmDeleteCurrentPage,
              ),

              // 2. AI Refinement Indicator Banner
              if (_isRefining)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: AppColors.royalBurgundy,
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.champagneGold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _refinementStage,
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. Quick Element Insertion Bar (Add Text / Add Shape)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                color: AppColors.deepNavy.withValues(alpha: 0.6),
                child: Row(
                  children: [
                    Text(
                      'إضافة عناصر:',
                      style: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _addNewTextElement,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceNavy,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 14,
                              color: AppColors.champagneGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+ نص',
                              style: GoogleFonts.tajawal(
                                color: AppColors.champagneGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _addNewShapeElement,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceNavy,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.35,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 14,
                              color: AppColors.champagneGold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+ شكل',
                              style: GoogleFonts.tajawal(
                                color: AppColors.champagneGold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (_selectedElementId != null)
                      InkWell(
                        onTap: () => setState(() => _selectedElementId = null),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: AppColors.warmIvory,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'إلغاء التحديد',
                              style: GoogleFonts.tajawal(
                                color: AppColors.warmIvory.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // 4. Interactive Canvas Workspace Area
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Tap on canvas background deselects elements
                    if (_selectedElementId != null) {
                      setState(() => _selectedElementId = null);
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const docWidth = 1080.0;
                          const docHeight = 1080.0;

                          // Compute scale dynamically to fit available screen space
                          final scale = min(
                            constraints.maxWidth / docWidth,
                            constraints.maxHeight / docHeight,
                          );

                          return SizedBox(
                            width: docWidth * scale,
                            height: docHeight * scale,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(
                                  int.tryParse(
                                        (currPage?.background?.color ??
                                                '#0B132B')
                                            .replaceAll('#', '0xFF'),
                                      ) ??
                                      0xFF0B132B,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Background image
                                  if (currPage?.background?.imageUrl != null)
                                    Image.network(
                                      currPage!.background!.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          const SizedBox.shrink(),
                                    ),

                                  // Editable Elements with Drag-and-Drop & Live Selection
                                  if (currPage != null)
                                    ...currPage.elements.map((el) {
                                      return _buildCanvasElement(el, scale);
                                    }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Contextual Properties Panel (Text / Generic) OR Layer Inspector
              if (selectedElement != null && selectedElement.type == 'text')
                TextPropertiesSheet(
                  element: selectedElement,
                  onContentChanged: _updateTextContent,
                  onFontFamilyChanged: _updateFontFamily,
                  onFontSizeChanged: _updateFontSize,
                  onColorChanged: _updateTextColor,
                  onBoldToggled: _updateTextBold,
                  onItalicToggled: _updateTextItalic,
                  onAlignmentChanged: _updateTextAlignment,
                  onDuplicate: () => _duplicateElement(selectedElement.id),
                  onDelete: () => _deleteElement(selectedElement.id),
                  onBringToFront: () => _bringToFront(selectedElement.id),
                  onSendToBack: () => _sendToBack(selectedElement.id),
                )
              else if (selectedElement != null)
                GenericPropertiesSheet(
                  element: selectedElement,
                  onColorChanged: selectedElement.type == 'shape'
                      ? _updateShapeColor
                      : null,
                  onOpacityChanged: _updateElementOpacity,
                  onDuplicate: () => _duplicateElement(selectedElement.id),
                  onDelete: () => _deleteElement(selectedElement.id),
                  onBringToFront: () => _bringToFront(selectedElement.id),
                  onSendToBack: () => _sendToBack(selectedElement.id),
                )
              else
                _buildDefaultBottomBar(currPage),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CANVAS ELEMENT RENDERER (DRAG & DROP + TOUCH)
  // ===========================================================================

  Widget _buildCanvasElement(DocumentElement el, double scale) {
    final isSelected = _selectedElementId == el.id;

    Widget childWidget;

    if (el.type == 'text') {
      final fontSize = (el.style['fontSize'] as num?)?.toDouble() ?? 24.0;
      final colorHex = el.style['color'] as String? ?? '#D4AF37';
      final isRTL = el.style['isRTL'] as bool? ?? true;
      final fontFamily = el.style['fontFamily'] as String? ?? 'Tajawal';
      final isBold =
          el.style['fontWeight'] == 'bold' || el.style['fontWeight'] == '800';
      final isItalic = el.style['fontStyle'] == 'italic';
      final alignment = el.style['textAlign'] as String? ?? 'center';

      TextAlign align;
      switch (alignment) {
        case 'right':
          align = TextAlign.right;
          break;
        case 'left':
          align = TextAlign.left;
          break;
        case 'center':
        default:
          align = TextAlign.center;
          break;
      }

      childWidget = Text(
        el.content,
        textAlign: align,
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        style: EditorFontHelper.getTextStyle(
          fontFamily,
          fontSize: (fontSize * scale * 2.8).clamp(9.0, 54.0),
          color: Color(
            int.tryParse(colorHex.replaceAll('#', '0xFF')) ?? 0xFFD4AF37,
          ),
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          shadows: const [
            Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
      );
    } else if (el.type == 'image') {
      childWidget = ClipRRect(
        borderRadius: BorderRadius.circular(
          ((el.style['borderRadius'] as num?)?.toDouble() ?? 12.0) * scale,
        ),
        child: Image.network(
          el.content,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            color: AppColors.surfaceNavy,
            child: const Icon(
              Icons.image_rounded,
              color: AppColors.champagneGold,
            ),
          ),
        ),
      );
    } else if (el.type == 'shape') {
      final fillColorHex = el.style['fillColor'] as String? ?? '#7A0E2C';
      final borderColorHex = el.style['borderColor'] as String? ?? '#D4AF37';
      final radius =
          ((el.style['borderRadius'] as num?)?.toDouble() ?? 8.0) * scale;
      final borderWidth =
          ((el.style['borderWidth'] as num?)?.toDouble() ?? 1.0) * scale;

      childWidget = Container(
        decoration: BoxDecoration(
          color: Color(
            int.tryParse(fillColorHex.replaceAll('#', '0xFF')) ?? 0xFF7A0E2C,
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Color(
              int.tryParse(borderColorHex.replaceAll('#', '0xFF')) ??
                  0xFFD4AF37,
            ),
            width: borderWidth.clamp(0.5, 4.0),
          ),
        ),
      );
    } else {
      childWidget = const SizedBox.shrink();
    }

    return Positioned(
      left: el.x * scale,
      top: el.y * scale,
      width: el.width * scale,
      height: el.height * scale,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedElementId = el.id);
        },
        onPanStart: (details) {
          setState(() => _selectedElementId = el.id);
          _recordHistory();
        },
        onPanUpdate: (details) {
          final docDeltaX = details.delta.dx / scale;
          final docDeltaY = details.delta.dy / scale;
          _moveElement(el.id, docDeltaX, docDeltaY);
        },
        onPanEnd: (details) {
          _scheduleAutosave();
        },
        child: Opacity(
          opacity: el.opacity.clamp(0.1, 1.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? AppColors.champagneGold
                    : Colors.transparent,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.champagneGold.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: childWidget),
                // Corner selection handles when selected
                if (isSelected) ...[
                  Positioned(top: -4, right: -4, child: _buildHandleDot()),
                  Positioned(bottom: -4, left: -4, child: _buildHandleDot()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandleDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.champagneGold,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.deepNavy, width: 1.5),
      ),
    );
  }

  // ===========================================================================
  // DEFAULT BOTTOM BAR (LAYER INSPECTOR & GENERAL ACTIONS)
  // ===========================================================================

  Widget _buildDefaultBottomBar(DocumentPage? currPage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceNavy,
        border: Border(top: BorderSide(color: Color(0x33D4AF37), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.layers_rounded,
                    color: AppColors.champagneGold,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'طبقات الصفحة الحالية (${currPage?.elements.length ?? 0})',
                    style: GoogleFonts.tajawal(
                      color: AppColors.champagneGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                'المس أي عنصر لتحريكه أو تعديله',
                style: GoogleFonts.tajawal(
                  color: AppColors.warmIvory.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Horizontal Layer Chips
          if (currPage != null && currPage.elements.isNotEmpty)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: currPage.elements.map((el) {
                  final isSelected = _selectedElementId == el.id;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            el.type == 'text'
                                ? Icons.text_fields_rounded
                                : el.type == 'image'
                                ? Icons.image_rounded
                                : Icons.category_rounded,
                            size: 14,
                            color: isSelected
                                ? AppColors.deepNavy
                                : AppColors.champagneGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            el.content.length > 18
                                ? '${el.content.substring(0, 18)}...'
                                : el.content,
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
                        ],
                      ),
                      backgroundColor: isSelected
                          ? AppColors.champagneGold
                          : AppColors.deepNavy,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.champagneGold
                            : AppColors.champagneGold.withValues(alpha: 0.3),
                      ),
                      onPressed: () {
                        setState(() => _selectedElementId = el.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 10),

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _navigateHome,
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: Text(
                    'الرئيسية',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.champagneGold,
                    side: const BorderSide(color: AppColors.champagneGold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _handleManualSave,
                  icon: const Icon(Icons.cloud_done_rounded, size: 18),
                  label: Text(
                    'حفظ التعديلات في السحابة',
                    style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: AppColors.deepNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
