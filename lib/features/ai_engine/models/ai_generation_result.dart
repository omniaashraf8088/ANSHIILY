import '../../templates/models/document_structure.dart';

class AiGenerationResult {
  final bool isSuccess;
  final String? errorMessage;
  final TemplateDocument? document;
  final String provider;
  final bool apiKeyConfigured;
  final int latencyMs;

  const AiGenerationResult({
    required this.isSuccess,
    this.errorMessage,
    this.document,
    this.provider = 'built-in-synthesizer',
    this.apiKeyConfigured = false,
    this.latencyMs = 0,
  });

  factory AiGenerationResult.success({
    required TemplateDocument document,
    String provider = 'built-in-synthesizer',
    bool apiKeyConfigured = false,
    int latencyMs = 0,
  }) {
    return AiGenerationResult(
      isSuccess: true,
      document: document,
      provider: provider,
      apiKeyConfigured: apiKeyConfigured,
      latencyMs: latencyMs,
    );
  }

  factory AiGenerationResult.failure(String error) {
    return AiGenerationResult(isSuccess: false, errorMessage: error);
  }
}
