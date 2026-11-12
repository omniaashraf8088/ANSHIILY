class AiGenerationRequest {
  final String prompt;
  final String category;
  final String style;
  final String aspectRatio;
  final double width;
  final double height;
  final String? brandName;
  final String? mainHeading;
  final String? supportingText;
  final String? targetAudience;
  final List<String> preferredColors;
  final String? templateId;
  final String? refinementCommand;
  final Map<String, dynamic>? currentDocument;

  const AiGenerationRequest({
    required this.prompt,
    this.category = 'social-media',
    this.style = 'luxury',
    this.aspectRatio = '1:1',
    this.width = 1080,
    this.height = 1080,
    this.brandName,
    this.mainHeading,
    this.supportingText,
    this.targetAudience,
    this.preferredColors = const ['#0B132B', '#D4AF37', '#7A0E2C', '#F6E9D8'],
    this.templateId,
    this.refinementCommand,
    this.currentDocument,
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'category': category,
    'style': style,
    'aspectRatio': aspectRatio,
    'width': width,
    'height': height,
    if (brandName != null) 'brandName': brandName,
    if (mainHeading != null) 'mainHeading': mainHeading,
    if (supportingText != null) 'supportingText': supportingText,
    if (targetAudience != null) 'targetAudience': targetAudience,
    'preferredColors': preferredColors,
    if (templateId != null) 'templateId': templateId,
    if (refinementCommand != null) 'refinementCommand': refinementCommand,
    if (currentDocument != null) 'currentDocument': currentDocument,
  };
}
