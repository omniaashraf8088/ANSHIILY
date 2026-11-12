import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../models/ai_generation_request.dart';
import '../services/ai_design_service.dart';

class GuidedCreationWizardScreen extends StatefulWidget {
  final String? initialPrompt;

  const GuidedCreationWizardScreen({super.key, this.initialPrompt});

  @override
  State<GuidedCreationWizardScreen> createState() =>
      _GuidedCreationWizardScreenState();
}

class _GuidedCreationWizardScreenState
    extends State<GuidedCreationWizardScreen> {
  int _currentStep = 0; // 0 to 4 (5 steps)

  // Step 1: Category
  String _selectedCategory = 'social-media';

  final List<Map<String, dynamic>> _categories = [
    {
      'slug': 'social-media',
      'nameAr': 'منشور سوشيال ميديا',
      'nameEn': 'Social Media Post',
      'icon': Icons.share_rounded,
      'defaultRatio': '1:1',
      'w': 1080.0,
      'h': 1080.0,
    },
    {
      'slug': 'story',
      'nameAr': 'قصة انستغرام ستوري',
      'nameEn': 'Instagram Story',
      'icon': Icons.phone_android_rounded,
      'defaultRatio': '9:16',
      'w': 1080.0,
      'h': 1920.0,
    },
    {
      'slug': 'marketing',
      'nameAr': 'إعلان ترويجي',
      'nameEn': 'Advertisement',
      'icon': Icons.campaign_rounded,
      'defaultRatio': '16:9',
      'w': 1200.0,
      'h': 628.0,
    },
    {
      'slug': 'flyers',
      'nameAr': 'فلاير دعائي',
      'nameEn': 'Flyer',
      'icon': Icons.feed_rounded,
      'defaultRatio': 'A4 Portrait',
      'w': 1240.0,
      'h': 1754.0,
    },
    {
      'slug': 'brochures',
      'nameAr': 'بروشور تعريفي',
      'nameEn': 'Brochure',
      'icon': Icons.menu_book_rounded,
      'defaultRatio': 'A4 Landscape',
      'w': 1754.0,
      'h': 1240.0,
    },
    {
      'slug': 'business-documents',
      'nameAr': 'مستند أعمال رسمي',
      'nameEn': 'Business Document',
      'icon': Icons.description_rounded,
      'defaultRatio': 'A4 Portrait',
      'w': 1240.0,
      'h': 1754.0,
    },
    {
      'slug': 'presentations',
      'nameAr': 'عرض تقديمي',
      'nameEn': 'Presentation',
      'icon': Icons.slideshow_rounded,
      'defaultRatio': '16:9',
      'w': 1920.0,
      'h': 1080.0,
    },
    {
      'slug': 'invitations',
      'nameAr': 'بطاقة دعوة فاخرة',
      'nameEn': 'Invitation',
      'icon': Icons.mail_outline_rounded,
      'defaultRatio': '4:5',
      'w': 1080.0,
      'h': 1350.0,
    },
    {
      'slug': 'planners',
      'nameAr': 'مخطط وجدول أهداف',
      'nameEn': 'Planner',
      'icon': Icons.calendar_today_rounded,
      'defaultRatio': 'A4 Portrait',
      'w': 1240.0,
      'h': 1754.0,
    },
    {
      'slug': 'custom',
      'nameAr': 'تصميم مخصص',
      'nameEn': 'Custom Design',
      'icon': Icons.dashboard_customize_rounded,
      'defaultRatio': '1:1',
      'w': 1080.0,
      'h': 1080.0,
    },
  ];

  // Step 2: Idea Prompt
  late final TextEditingController _promptController;

  final List<String> _quickSuggestions = [
    'إعلان فاخر لمنتج عناية بالبشرة بالذهبي والعاجي',
    'دعوة حفل تدشين علامة عطور ملكية راقية',
    'بانر ترويجي لخصومات الجمعة الذهبية لمقهى عصري',
    'عرض تقديمي جذاب لشركة استثمار ناشئة',
    'بطاقة تهنئة فاخرة بلمسات كحلية وخط كوفي أصيل',
  ];

  // Step 3: Design Info
  final _titleController = TextEditingController();
  final _mainHeadingController = TextEditingController();
  final _supportingTextController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _targetAudienceController = TextEditingController();
  String _selectedStyle = 'فاخر ذهبي (Luxury Gold)';
  final List<String> _styles = [
    'فاخر ذهبي (Luxury Gold)',
    'عصري مينيمال (Modern Minimal)',
    'ملكي كلاسيكي (Royal Classic)',
    'تقني نيون (Futuristic Neon)',
    'هادئ وناعم (Pastel Elegant)',
  ];

  // Step 4: Dimensions
  String _selectedDimensionName = 'Instagram Post 1:1';
  double _customWidth = 1080;
  double _customHeight = 1080;

  final List<Map<String, dynamic>> _dimensionPresets = [
    {
      'name': 'Instagram Post 1:1',
      'w': 1080.0,
      'h': 1080.0,
      'desc': '1080 × 1080 بكسل',
    },
    {
      'name': 'Instagram Story 9:16',
      'w': 1080.0,
      'h': 1920.0,
      'desc': '1080 × 1920 بكسل',
    },
    {
      'name': 'Facebook Post 16:9',
      'w': 1200.0,
      'h': 628.0,
      'desc': '1200 × 628 بكسل',
    },
    {
      'name': 'A4 Portrait',
      'w': 1240.0,
      'h': 1754.0,
      'desc': '1240 × 1754 بكسل',
    },
    {
      'name': 'A4 Landscape',
      'w': 1754.0,
      'h': 1240.0,
      'desc': '1754 × 1240 بكسل',
    },
    {
      'name': 'Presentation 16:9',
      'w': 1920.0,
      'h': 1080.0,
      'desc': '1920 × 1080 بكسل',
    },
  ];

  // Step 5: Generation State
  bool _isGenerating = false;
  String _generationStage = '';
  double _generationProgress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.initialPrompt ?? '');
    if (widget.initialPrompt?.isNotEmpty == true) {
      _titleController.text = widget.initialPrompt!.split('\n').first.trim();
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    _mainHeadingController.dispose();
    _supportingTextController.dispose();
    _brandNameController.dispose();
    _targetAudienceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1 && _promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى كتابة فكرة أو وصف للتصميم للاستمرار.',
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: AppColors.champagneGold,
        ),
      );
      return;
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _startGeneration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generationProgress = 0.1;
      _generationStage = 'بدء تشغيل محرك الذكاء الاصطناعي ANSHIILY AI...';
    });

    final request = AiGenerationRequest(
      prompt: _promptController.text.trim(),
      category: _selectedCategory,
      style: _selectedStyle,
      aspectRatio: _selectedDimensionName,
      width: _customWidth,
      height: _customHeight,
      brandName: _brandNameController.text.trim().isNotEmpty
          ? _brandNameController.text.trim()
          : null,
      mainHeading: _mainHeadingController.text.trim().isNotEmpty
          ? _mainHeadingController.text.trim()
          : null,
      supportingText: _supportingTextController.text.trim().isNotEmpty
          ? _supportingTextController.text.trim()
          : null,
      targetAudience: _targetAudienceController.text.trim().isNotEmpty
          ? _targetAudienceController.text.trim()
          : null,
    );

    try {
      final result = await AiDesignService.instance.generateDesign(
        request,
        onProgress: (stage, progress) {
          if (mounted) {
            setState(() {
              _generationStage = stage;
              _generationProgress = progress;
            });
          }
        },
      );

      if (!result.isSuccess || result.document == null) {
        throw Exception(result.errorMessage ?? 'فشل توليد التصميم');
      }

      final doc = result.document!;
      final projectTitle = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : (_promptController.text.trim().split('\n').first.trim());

      final created = await AiDesignService.instance.saveGeneratedProject(
        title: projectTitle,
        prompt: _promptController.text.trim(),
        document: doc,
        style: _selectedStyle,
        aspectRatio: _selectedDimensionName,
      );

      if (!mounted) return;
      setState(() => _isGenerating = false);

      if (created != null) {
        context.pushReplacement(
          AppRoutes.projectEditor,
          extra: {'project': created, 'initialDocument': doc},
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _errorMessage = 'حدث خطأ أثناء التوليد: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.champagneGold,
            size: 20,
          ),
          onPressed: _previousStep,
        ),
        title: Text(
          'مساعد التصميم الذكي (الخطوة ${_currentStep + 1} من 5)',
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _isGenerating
            ? _buildGeneratingView()
            : Column(
                children: [
                  // Progress line
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentStep + 1) / 5.0,
                        backgroundColor: AppColors.surfaceNavy,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.champagneGold,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentStepContent(),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceNavy,
                      border: const Border(
                        top: BorderSide(color: Color(0x33D4AF37), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            flex: 1,
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.champagneGold,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: Text(
                                'السابق',
                                style: GoogleFonts.tajawal(
                                  color: AppColors.champagneGold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.champagneGold,
                              foregroundColor: AppColors.deepNavy,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentStep == 4
                                      ? 'توليد التصميم الآن ✨'
                                      : 'متابعة',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentStep == 4
                                      ? Icons.auto_awesome_rounded
                                      : Icons.arrow_back_ios_new_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Category();
      case 1:
        return _buildStep2Prompt();
      case 2:
        return _buildStep3Details();
      case 3:
        return _buildStep4Dimensions();
      case 4:
        return _buildStep5Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: CATEGORY SELECTION
  Widget _buildStep1Category() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ماذا تريد أن تصمم اليوم؟',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'اختر نوع التصميم ليقوم الذكاء الاصطناعي بتهيئة القياسات والتكوين الأنسب.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final isSelected = _selectedCategory == cat['slug'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = cat['slug'] as String;
                  _customWidth = cat['w'] as double;
                  _customHeight = cat['h'] as double;
                  _selectedDimensionName = cat['defaultRatio'] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.champagneGold.withValues(alpha: 0.15)
                      : AppColors.surfaceNavy,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.champagneGold
                        : AppColors.champagneGold.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      color: isSelected
                          ? AppColors.champagneGold
                          : AppColors.warmIvory.withValues(alpha: 0.8),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['nameAr'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        color: isSelected
                            ? AppColors.champagneGold
                            : AppColors.warmIvory,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                    Text(
                      cat['nameEn'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.tajawal(
                        color: AppColors.warmIvory.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 2: DESCRIBE IDEA
  Widget _buildStep2Prompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'احكِ لنا عن فكرتك بالتفصيل ✨',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'يمكنك الكتابة بالعربية أو الإنجليزية، أوصف المنتج أو الفعالية أو النمط المطلوب.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.35),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _promptController,
            maxLines: 6,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(
              color: AppColors.warmIvory,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText:
                  'مثال: صمم إعلاناً فاخراً لمنتج عناية بالبشرة مع لمسات ذهبية وعاجية، وخط كوفي ملكي وتكوين متوازن...',
              hintStyle: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'أفكار واقتراحات سريعة:',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickSuggestions.map((sug) {
            return ActionChip(
              backgroundColor: AppColors.surfaceNavy,
              side: BorderSide(
                color: AppColors.champagneGold.withValues(alpha: 0.3),
              ),
              label: Text(
                sug,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.tajawal(
                  color: AppColors.warmIvory.withValues(alpha: 0.85),
                  fontSize: 12,
                ),
              ),
              onPressed: () {
                setState(() => _promptController.text = sug);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 3: DESIGN INFORMATION
  Widget _buildStep3Details() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'معلومات وتفاصيل التصميم',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'هذه الحقول اختيارية، تساعد الذكاء الاصطناعي على تخصيص النصوص والعناصر بدقة أعلى.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          'اسم البراند أو العلامة التجارية',
          _brandNameController,
        ),
        const SizedBox(height: 14),
        _buildTextField('العنوان الرئيسي البارز', _mainHeadingController),
        const SizedBox(height: 14),
        _buildTextField(
          'النص الفرعي أو العبارة الترويجية',
          _supportingTextController,
        ),
        const SizedBox(height: 14),
        _buildTextField('الجمهور المستهدف', _targetAudienceController),
        const SizedBox(height: 18),
        Text(
          'الأسلوب والنمط البصري (Style):',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStyle,
              dropdownColor: AppColors.deepNavy,
              isExpanded: true,
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              items: _styles.map((s) {
                return DropdownMenuItem(value: s, child: Text(s));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStyle = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // STEP 4: DIMENSIONS
  Widget _buildStep4Dimensions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختر أبعاد ومقاسات التصميم',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'حدد المقاس المناسب للمنصة أو المطبوعات الرقمية.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dimensionPresets.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final preset = _dimensionPresets[index];
            final isSelected = _selectedDimensionName == preset['name'];

            return ListTile(
              onTap: () {
                setState(() {
                  _selectedDimensionName = preset['name'] as String;
                  _customWidth = preset['w'] as double;
                  _customHeight = preset['h'] as double;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.champagneGold
                      : AppColors.champagneGold.withValues(alpha: 0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              tileColor: isSelected
                  ? AppColors.champagneGold.withValues(alpha: 0.12)
                  : AppColors.surfaceNavy,
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected
                    ? AppColors.champagneGold
                    : AppColors.warmIvory.withValues(alpha: 0.4),
              ),
              title: Text(
                preset['name'] as String,
                style: GoogleFonts.tajawal(
                  color: isSelected
                      ? AppColors.champagneGold
                      : AppColors.warmIvory,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                preset['desc'] as String,
                style: GoogleFonts.tajawal(
                  color: AppColors.warmIvory.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 5: REVIEW & SUMMARY
  Widget _buildStep5Review() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'مراجعة ملخص التصميم',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.champagneGold,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'راجع الخيارات التي تم تحديدها قبل بدء عملية التوليد الذكي.',
          textDirection: TextDirection.rtl,
          style: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceNavy,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.champagneGold.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              _buildSummaryRow('التصنيف', _selectedCategory),
              const Divider(color: Color(0x22D4AF37), height: 18),
              _buildSummaryRow(
                'الأبعاد',
                '$_selectedDimensionName (${_customWidth.toInt()}×${_customHeight.toInt()})',
              ),
              const Divider(color: Color(0x22D4AF37), height: 18),
              _buildSummaryRow('الأسلوب', _selectedStyle),
              const Divider(color: Color(0x22D4AF37), height: 18),
              _buildSummaryRow('الفكرة', _promptController.text.trim()),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.royalBurgundy.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.royalBurgundy.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.champagneGold,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'سيقوم المحرك بإنشاء مستند حقيقي متعدد الطبقات (نصوص، صور، أشكال) يمكن تعديله بالكامل.',
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.tajawal(
                    color: AppColors.warmIvory,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              color: AppColors.warmIvory.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.tajawal(
              color: AppColors.champagneGold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceNavy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.25),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        style: GoogleFonts.tajawal(color: AppColors.warmIvory, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.tajawal(
            color: AppColors.warmIvory.withValues(alpha: 0.4),
            fontSize: 13,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // GENERATING ANIMATED VIEW
  Widget _buildGeneratingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.royalBurgundy, AppColors.deepNavy],
                ),
                border: Border.all(color: AppColors.champagneGold, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.champagneGold.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.champagneGold,
                size: 54,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'محرك الذكاء الاصطناعي يبدع الآن...',
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _generationStage,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.tajawal(
                color: AppColors.warmIvory.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _generationProgress,
                  backgroundColor: AppColors.surfaceNavy,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.champagneGold,
                  ),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_generationProgress * 100).toInt()}%',
              style: GoogleFonts.tajawal(
                color: AppColors.champagneGold,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  color: Colors.redAccent,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _startGeneration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.champagneGold,
                  foregroundColor: AppColors.deepNavy,
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
