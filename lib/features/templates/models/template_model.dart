import 'document_structure.dart';

class TemplateModel {
  final String id;
  final String? categoryId;
  final String categorySlug;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;
  final String thumbnailUrl;
  final String previewUrl;
  final double width;
  final double height;
  final int pageCount;
  final bool isPremium;
  final bool isFeatured;
  final int popularityScore;
  final TemplateDocument documentData;
  final DateTime createdAt;

  const TemplateModel({
    required this.id,
    this.categoryId,
    required this.categorySlug,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.thumbnailUrl,
    required this.previewUrl,
    this.width = 1080,
    this.height = 1080,
    this.pageCount = 1,
    this.isPremium = false,
    this.isFeatured = false,
    this.popularityScore = 0,
    required this.documentData,
    required this.createdAt,
  });

  String get dimensionsString => '${width.toInt()} × ${height.toInt()} بكسل';
  double get aspectRatio => width > 0 && height > 0 ? width / height : 1.0;

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      categoryId: json['category_id'] as String?,
      categorySlug: json['category_slug'] as String? ?? 'social-media',
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? '',
      descriptionEn: json['description_en'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      previewUrl: json['preview_url'] as String? ?? '',
      width: (json['width'] as num?)?.toDouble() ?? 1080,
      height: (json['height'] as num?)?.toDouble() ?? 1080,
      pageCount: (json['page_count'] as num?)?.toInt() ?? 1,
      isPremium: json['is_premium'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      popularityScore: (json['popularity_score'] as num?)?.toInt() ?? 0,
      documentData:
          json['document_data'] != null &&
              json['document_data'] is Map<String, dynamic>
          ? TemplateDocument.fromJson(
              json['document_data'] as Map<String, dynamic>,
            )
          : TemplateDocument(
              pages: [
                DocumentPage(
                  id: 'page_1',
                  elements: [
                    DocumentElement(
                      id: 'default_text',
                      type: 'text',
                      content: json['name_ar'] as String? ?? 'تصميم جديد',
                      x: 50,
                      y: 50,
                      width: 400,
                      height: 60,
                    ),
                  ],
                ),
              ],
            ),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_slug': categorySlug,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'thumbnail_url': thumbnailUrl,
      'preview_url': previewUrl,
      'width': width,
      'height': height,
      'page_count': pageCount,
      'is_premium': isPremium,
      'is_featured': isFeatured,
      'popularity_score': popularityScore,
      'document_data': documentData.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Initial Seed Dataset of Premium International Templates
  static List<TemplateModel> get defaults => [
    TemplateModel(
      id: 'tpl-1',
      categorySlug: 'social-media',
      nameAr: 'بوست انستغرام فخم بالخط الكوفي',
      nameEn: 'Luxury Kufic Instagram Post',
      descriptionAr:
          'قالب مربع راقٍ بتدرجات كحلية وذهبية مع نصوص قابلة للتعديل وصورة مركزية.',
      descriptionEn:
          'Square luxury template with navy and gold gradients and editable typography.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=600&q=80',
      previewUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
      width: 1080,
      height: 1080,
      pageCount: 1,
      isPremium: false,
      isFeatured: true,
      popularityScore: 98,
      documentData: TemplateDocument(
        pages: [
          DocumentPage(
            id: 'page_1',
            background: const PageBackground(color: '#0B132B'),
            elements: const [
              DocumentElement(
                id: 'title',
                type: 'text',
                content: 'أصالة وإبداع',
                x: 100,
                y: 180,
                width: 880,
                height: 120,
                style: {
                  'fontSize': 48,
                  'color': '#D4AF37',
                  'fontWeight': 'bold',
                  'textAlign': 'center',
                },
              ),
              DocumentElement(
                id: 'body',
                type: 'text',
                content: 'حوّل شغفك إلى واقع ملموس مع أرقى الحلول الإبداعية',
                x: 140,
                y: 320,
                width: 800,
                height: 100,
                style: {
                  'fontSize': 24,
                  'color': '#F6E9D8',
                  'textAlign': 'center',
                },
              ),
              DocumentElement(
                id: 'hero_img',
                type: 'image',
                content:
                    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=800&q=80',
                x: 140,
                y: 440,
                width: 800,
                height: 500,
                style: {'borderRadius': 24},
              ),
            ],
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    TemplateModel(
      id: 'tpl-2',
      categorySlug: 'marketing',
      nameAr: 'بانر ترويجي لعروض نهاية الموسم',
      nameEn: 'End of Season Promo Banner',
      descriptionAr:
          'تصميم ترويجي عريض للإعلانات وحملات التخفيضات مع شارات خصم بارزة.',
      descriptionEn:
          'Wide promotional design for sales campaigns with prominent discount badges.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=600&q=80',
      previewUrl:
          'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=1200&q=80',
      width: 1200,
      height: 628,
      pageCount: 1,
      isPremium: true,
      isFeatured: true,
      popularityScore: 95,
      documentData: TemplateDocument(
        pages: [
          DocumentPage(
            id: 'page_1',
            background: const PageBackground(color: '#111B38'),
            elements: const [
              DocumentElement(
                id: 'offer',
                type: 'text',
                content: 'خصم يصل إلى 50%',
                x: 80,
                y: 120,
                width: 600,
                height: 90,
                style: {
                  'fontSize': 52,
                  'color': '#D4AF37',
                  'fontWeight': 'bold',
                },
              ),
              DocumentElement(
                id: 'sub',
                type: 'text',
                content: 'لفترة محدودة - استمتع بأقوى العروض الحصرية',
                x: 80,
                y: 230,
                width: 550,
                height: 60,
                style: {'fontSize': 22, 'color': '#F6E9D8'},
              ),
            ],
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TemplateModel(
      id: 'tpl-3',
      categorySlug: 'presentations',
      nameAr: 'عرض تقديمي استثماري للشركات الناشئة',
      nameEn: 'Pitch Deck Presentation Slide',
      descriptionAr:
          'سلسلة شرائح متناسقة لعرض نماذج الأعمال، الإحصائيات، وخطط النمو.',
      descriptionEn:
          'Consistent presentation deck for business models, metrics, and growth plans.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=600&q=80',
      previewUrl:
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=1200&q=80',
      width: 1920,
      height: 1080,
      pageCount: 3,
      isPremium: true,
      isFeatured: true,
      popularityScore: 92,
      documentData: TemplateDocument(
        pages: [
          DocumentPage(
            id: 'slide_1',
            background: const PageBackground(color: '#0B132B'),
            elements: const [
              DocumentElement(
                id: 'deck_title',
                type: 'text',
                content: 'استراتيجية النمو 2027',
                x: 160,
                y: 300,
                width: 1200,
                height: 140,
                style: {
                  'fontSize': 64,
                  'color': '#D4AF37',
                  'fontWeight': 'bold',
                },
              ),
              DocumentElement(
                id: 'deck_sub',
                type: 'text',
                content: 'رؤية مستقبلية نحو التوسع والريادة',
                x: 160,
                y: 460,
                width: 1000,
                height: 80,
                style: {'fontSize': 32, 'color': '#F6E9D8'},
              ),
            ],
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    TemplateModel(
      id: 'tpl-4',
      categorySlug: 'invitations',
      nameAr: 'بطاقة دعوة زفاف ملكية فاخرة',
      nameEn: 'Royal Wedding Invitation Card',
      descriptionAr:
          'بطاقة رأسية فخمة بنقوش وزخارف ذهبية عربية أنيقة مع نصوص دعوة قابلة للتخصيص.',
      descriptionEn:
          'Vertical luxury invitation with ornate golden motifs and custom typography.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=600&q=80',
      previewUrl:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=1200&q=80',
      width: 1080,
      height: 1920,
      pageCount: 1,
      isPremium: false,
      isFeatured: true,
      popularityScore: 97,
      documentData: TemplateDocument(
        pages: [
          DocumentPage(
            id: 'page_1',
            background: const PageBackground(color: '#0B132B'),
            elements: const [
              DocumentElement(
                id: 'invite_title',
                type: 'text',
                content: 'دعوة زفاف خاصة',
                x: 100,
                y: 280,
                width: 880,
                height: 100,
                style: {
                  'fontSize': 44,
                  'color': '#D4AF37',
                  'textAlign': 'center',
                },
              ),
              DocumentElement(
                id: 'names',
                type: 'text',
                content: 'أحمد & مريم',
                x: 100,
                y: 420,
                width: 880,
                height: 120,
                style: {
                  'fontSize': 56,
                  'color': '#F6E9D8',
                  'textAlign': 'center',
                },
              ),
            ],
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    TemplateModel(
      id: 'tpl-5',
      categorySlug: 'brochures',
      nameAr: 'بروشور تعريفي لخدمات معمارية',
      nameEn: 'Architectural Studio Tri-fold Brochure',
      descriptionAr:
          'مطوية ثلاثية الصفحات تستعرض المشاريع الهندسية وخدمات التصميم الداخلي.',
      descriptionEn:
          'Tri-fold brochure highlighting architectural projects and interior services.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=600&q=80',
      previewUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=1200&q=80',
      width: 1920,
      height: 1080,
      pageCount: 2,
      isPremium: true,
      isFeatured: false,
      popularityScore: 88,
      documentData: TemplateDocument(
        pages: [
          DocumentPage(
            id: 'panel_1',
            background: const PageBackground(color: '#0E1830'),
            elements: const [
              DocumentElement(
                id: 'arch_title',
                type: 'text',
                content: 'الإبداع الهندسي الحديث',
                x: 120,
                y: 200,
                width: 600,
                height: 100,
                style: {'fontSize': 40, 'color': '#D4AF37'},
              ),
            ],
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    TemplateModel(
      id: 'tpl-6',
      categorySlug: 'business-documents',
      nameAr: 'سيرة ذاتية تنفيذية راقية',
      nameEn: 'Executive Modern Resume',
      descriptionAr:
          'نموذج سيرة ذاتية رسمي منسق بأسلوب حديث يبرز الخبرات والمهارات القيادية.',
      descriptionEn:
          'Official modern resume layout emphasizing executive leadership and skills.',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=600&q=80',
      previewUrl:
          'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=1200&q=80',
      width: 1240,
      height: 1754,
      pageCount: 1,
      isPremium: false,
      isFeatured: false,
      popularityScore: 86,
      documentData: TemplateDocument(
        pages: [
          DocumentPage(
            id: 'page_1',
            background: const PageBackground(color: '#111B38'),
            elements: const [
              DocumentElement(
                id: 'name',
                type: 'text',
                content: 'محمد خالد العتيبي',
                x: 100,
                y: 140,
                width: 800,
                height: 90,
                style: {'fontSize': 48, 'color': '#D4AF37'},
              ),
            ],
          ),
        ],
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
}
