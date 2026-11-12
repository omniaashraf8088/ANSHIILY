class ProjectModel {
  final String id;
  final String userId;
  final String title;
  final String prompt;
  final String? imageUrl;
  final String status;
  final String? style;
  final String? aspectRatio;
  final bool isPublic;
  final String? templateId;
  final Map<String, dynamic>? documentData;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.prompt,
    this.imageUrl,
    this.status = 'draft',
    this.style,
    this.aspectRatio = '1:1',
    this.isPublic = false,
    this.templateId,
    this.documentData,
    required this.createdAt,
    this.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'مشروع بدون عنوان',
      prompt: json['prompt'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'draft',
      style: json['style'] as String?,
      aspectRatio: json['aspect_ratio'] as String? ?? '1:1',
      isPublic: json['is_public'] as bool? ?? false,
      templateId: json['template_id'] as String?,
      documentData: json['document_data'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'prompt': prompt,
      'image_url': imageUrl,
      'status': status,
      'style': style,
      'aspect_ratio': aspectRatio,
      'is_public': isPublic,
      'template_id': templateId,
      'document_data': documentData,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'prompt': prompt,
      'status': status,
      'is_public': isPublic,
    };
    if (imageUrl != null) map['image_url'] = imageUrl;
    if (style != null) map['style'] = style;
    if (aspectRatio != null) map['aspect_ratio'] = aspectRatio;
    return map;
  }

  ProjectModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? prompt,
    String? imageUrl,
    String? status,
    String? style,
    String? aspectRatio,
    bool? isPublic,
    String? templateId,
    Map<String, dynamic>? documentData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      style: style ?? this.style,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isPublic: isPublic ?? this.isPublic,
      templateId: templateId ?? this.templateId,
      documentData: documentData ?? this.documentData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get statusDisplayArabic {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'generating':
        return 'قيد المعالجة';
      case 'draft':
      default:
        return 'مسودة';
    }
  }
}
