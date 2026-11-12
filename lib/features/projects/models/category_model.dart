class CategoryModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String slug;
  final String? descriptionAr;
  final String? descriptionEn;
  final String iconName;
  final String? coverImage;
  final bool isActive;
  final int displayOrder;

  const CategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.slug,
    this.descriptionAr,
    this.descriptionEn,
    required this.iconName,
    this.coverImage,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      iconName: json['icon_name'] as String? ?? 'brush',
      coverImage: json['cover_image'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'slug': slug,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'icon_name': iconName,
      'cover_image': coverImage,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }

  /// Initial Seed Dataset of 10 Expandable Design Categories
  static List<CategoryModel> get defaults => const [
    CategoryModel(
      id: 'cat-1',
      nameAr: 'تصاميم منصات التواصل',
      nameEn: 'Social Media Designs',
      slug: 'social-media',
      descriptionAr: 'قوالب انستغرام، فيسبوك، وتيك توك احترافية',
      descriptionEn: 'Templates for Instagram, Facebook, and TikTok',
      iconName: 'share',
      coverImage:
          'https://images.unsplash.com/photo-1611162617474-5b21e879e113?auto=format&fit=crop&w=800&q=80',
      displayOrder: 1,
    ),
    CategoryModel(
      id: 'cat-2',
      nameAr: 'التسويق والإعلانات',
      nameEn: 'Marketing & Advertising',
      slug: 'marketing',
      descriptionAr: 'حملات إعلانية، بانرات، ولافتات ترويجية جذابة',
      descriptionEn: 'Advertising campaigns, banners, and promotional designs',
      iconName: 'campaign',
      coverImage:
          'https://images.unsplash.com/photo-1460925895917-afdab827c52f?auto=format&fit=crop&w=800&q=80',
      displayOrder: 2,
    ),
    CategoryModel(
      id: 'cat-3',
      nameAr: 'البروشورات',
      nameEn: 'Brochures',
      slug: 'brochures',
      descriptionAr: 'كتيبات ومطويات تسويقية ثنائية وثلاثية الطيات',
      descriptionEn: 'Bi-fold and tri-fold marketing brochures',
      iconName: 'menu_book',
      coverImage:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=800&q=80',
      displayOrder: 3,
    ),
    CategoryModel(
      id: 'cat-4',
      nameAr: 'الفلايرات الدعائية',
      nameEn: 'Flyers',
      slug: 'flyers',
      descriptionAr: 'منشورات ورقية ورقمية للفعاليات والأنشطة',
      descriptionEn: 'Digital and print flyers for events and promotions',
      iconName: 'feed',
      coverImage:
          'https://images.unsplash.com/photo-1586281380349-632531db7ed4?auto=format&fit=crop&w=800&q=80',
      displayOrder: 4,
    ),
    CategoryModel(
      id: 'cat-5',
      nameAr: 'المستندات المهنية',
      nameEn: 'Business Documents',
      slug: 'business-documents',
      descriptionAr: 'فواتير، مراسلات رسمية، وسير ذاتية فاخرة',
      descriptionEn: 'Invoices, letterheads, and executive resumes',
      iconName: 'description',
      coverImage:
          'https://images.unsplash.com/photo-1450133064473-71024230f91b?auto=format&fit=crop&w=800&q=80',
      displayOrder: 5,
    ),
    CategoryModel(
      id: 'cat-6',
      nameAr: 'المخططات والجداول',
      nameEn: 'Planners',
      slug: 'planners',
      descriptionAr: 'مخططات يومية، أسبوعية، ومنظمات أهداف سنوية',
      descriptionEn: 'Daily, weekly planners and goal organizers',
      iconName: 'calendar_today',
      coverImage:
          'https://images.unsplash.com/photo-1484480974693-6ca0a78fb36b?auto=format&fit=crop&w=800&q=80',
      displayOrder: 6,
    ),
    CategoryModel(
      id: 'cat-7',
      nameAr: 'العروض التقديمية',
      nameEn: 'Presentations',
      slug: 'presentations',
      descriptionAr: 'شرائح باوربوينت وعروض أعمال بأناقة عالية',
      descriptionEn: 'Modern presentation decks and pitch decks',
      iconName: 'slideshow',
      coverImage:
          'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=800&q=80',
      displayOrder: 7,
    ),
    CategoryModel(
      id: 'cat-8',
      nameAr: 'بطاقات الدعوة والتهنئة',
      nameEn: 'Invitations',
      slug: 'invitations',
      descriptionAr: 'دعوات أعراس، مناسبات، وبطاقات معايدة راقية',
      descriptionEn: 'Wedding invites, celebrations, and greeting cards',
      iconName: 'mail',
      coverImage:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?auto=format&fit=crop&w=800&q=80',
      displayOrder: 8,
    ),
    CategoryModel(
      id: 'cat-9',
      nameAr: 'التصاميم التعليمية',
      nameEn: 'Educational Designs',
      slug: 'educational',
      descriptionAr: 'ملصقات ومخططات بصرية للمدارس والجامعات',
      descriptionEn:
          'Infographics and visual aids for schools and universities',
      iconName: 'school',
      coverImage:
          'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=800&q=80',
      displayOrder: 9,
    ),
    CategoryModel(
      id: 'cat-10',
      nameAr: 'التصاميم الشخصية',
      nameEn: 'Personal Designs',
      slug: 'personal',
      descriptionAr: 'أغلفة مذكرات، خلفيات شاشة، وبطاقات ذكريات',
      descriptionEn: 'Wallpapers, journal covers, and memory albums',
      iconName: 'person',
      coverImage:
          'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?auto=format&fit=crop&w=800&q=80',
      displayOrder: 10,
    ),
  ];
}
