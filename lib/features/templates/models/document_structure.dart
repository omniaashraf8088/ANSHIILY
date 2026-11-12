class TemplateDocument {
  final List<DocumentPage> pages;
  final Map<String, dynamic> metadata;

  const TemplateDocument({required this.pages, this.metadata = const {}});

  factory TemplateDocument.fromJson(Map<String, dynamic> json) {
    final pagesRaw = json['pages'] as List<dynamic>? ?? [];
    return TemplateDocument(
      pages: pagesRaw
          .map((p) => DocumentPage.fromJson(p as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  TemplateDocument copyWith({
    List<DocumentPage>? pages,
    Map<String, dynamic>? metadata,
  }) {
    return TemplateDocument(
      pages: pages ?? this.pages,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'pages': pages.map((p) => p.toJson()).toList(),
    'metadata': metadata,
  };

  int get totalElements =>
      pages.fold<int>(0, (sum, page) => sum + page.elements.length);
}

class DocumentPage {
  final String id;
  final PageBackground? background;
  final List<DocumentElement> elements;

  const DocumentPage({
    required this.id,
    this.background,
    required this.elements,
  });

  factory DocumentPage.fromJson(Map<String, dynamic> json) {
    return DocumentPage(
      id: json['id'] as String? ?? 'page_1',
      background: json['background'] != null
          ? PageBackground.fromJson(json['background'] as Map<String, dynamic>)
          : null,
      elements: (json['elements'] as List<dynamic>? ?? [])
          .map((e) => DocumentElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DocumentPage copyWith({
    String? id,
    PageBackground? background,
    List<DocumentElement>? elements,
  }) {
    return DocumentPage(
      id: id ?? this.id,
      background: background ?? this.background,
      elements: elements ?? this.elements,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (background != null) 'background': background!.toJson(),
    'elements': elements.map((e) => e.toJson()).toList(),
  };
}

class PageBackground {
  final String? color;
  final String? imageUrl;

  const PageBackground({this.color, this.imageUrl});

  factory PageBackground.fromJson(Map<String, dynamic> json) => PageBackground(
    color: json['color'] as String?,
    imageUrl: json['imageUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (color != null) 'color': color,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };
}

class DocumentElement {
  final String id;
  final String type; // 'text', 'image', 'shape', 'decorative'
  final String content;
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation;
  final double opacity;
  final Map<String, dynamic> style;

  const DocumentElement({
    required this.id,
    required this.type,
    required this.content,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.style = const {},
  });

  factory DocumentElement.fromJson(Map<String, dynamic> json) {
    return DocumentElement(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      content: json['content'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 100.0,
      height: (json['height'] as num?)?.toDouble() ?? 40.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      style: json['style'] as Map<String, dynamic>? ?? const {},
    );
  }

  DocumentElement copyWith({
    String? id,
    String? type,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? opacity,
    Map<String, dynamic>? style,
  }) {
    return DocumentElement(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      opacity: opacity ?? this.opacity,
      style: style ?? this.style,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'content': content,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'rotation': rotation,
    'opacity': opacity,
    'style': style,
  };
}
