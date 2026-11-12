import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../projects/models/category_model.dart';

class AiAssistantCard extends StatefulWidget {
  final List<CategoryModel> categories;
  final VoidCallback onProjectCreated;

  const AiAssistantCard({
    super.key,
    required this.categories,
    required this.onProjectCreated,
  });

  @override
  State<AiAssistantCard> createState() => _AiAssistantCardState();
}

class _AiAssistantCardState extends State<AiAssistantCard> {
  final TextEditingController _promptController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _promptSuggestions = const [
    'شعار مقهى عصري بلمسات ذهبية',
    'إعلان انستغرام لمجموعة عطور ملكية',
    'سيرة ذاتية تنفيذية لمدير مشاريع',
    'بطاقة دعوة لحفل تخرج راقٍ',
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handleConvertIdea() async {
    if (!_formKey.currentState!.validate()) return;

    final ideaText = _promptController.text.trim();
    _promptController.clear();
    context.push(
      '${AppRoutes.aiWizard}?prompt=${Uri.encodeComponent(ideaText)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceNavy,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0x55D4AF37), Color(0x11D4AF37)],
                      ),
                      border: Border.all(
                        color: AppColors.champagneGold,
                        width: 1.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.champagneGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'عندك فكرة؟ احكيلنا عنها!',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.tajawal(
                          color: AppColors.champagneGold,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'المساعد الإبداعي الذكي من أنشئلي',
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.tajawal(
                          color: AppColors.warmIvory.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Idea Description Input
              TextFormField(
                controller: _promptController,
                maxLines: 3,
                style: GoogleFonts.tajawal(
                  color: AppColors.warmIvory,
                  fontSize: 14,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى كتابة وصف فكرتك الإبداعية أولاً';
                  }
                  if (val.trim().length < 5) {
                    return 'يرجى كتابة وصف أكثر تفصيلاً (5 أحرف على الأقل)';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText:
                      'مثال: أريد تصميم هوية بصرية أنيقة لمحل شوكولاتة فاخرة بألوان البني الداكن والذهبي...',
                  hintStyle: GoogleFonts.tajawal(
                    color: AppColors.warmIvory.withValues(alpha: 0.35),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  filled: true,
                  fillColor: AppColors.deepNavy,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.champagneGold.withValues(alpha: 0.25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.champagneGold.withValues(alpha: 0.25),
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

              const SizedBox(height: 12),

              // Suggestion Pills
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _promptSuggestions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final suggestion = _promptSuggestions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _promptController.text = suggestion);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.deepNavy,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            suggestion,
                            style: GoogleFonts.tajawal(
                              color: AppColors.warmIvory.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _handleConvertIdea,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: Text(
                    'حوّل فكرتك إلى تصميم',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.champagneGold,
                    foregroundColor: AppColors.deepNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
