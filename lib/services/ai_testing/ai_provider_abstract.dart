/// Represents a single message in an AI conversation.
class AiMessage {
  final String role;
  final String content;

  const AiMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Result returned by an AI provider after a completion request.
class AiCompletionResult {
  final String content;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final Duration latency;

  const AiCompletionResult({
    required this.content,
    required this.model,
    required this.promptTokens,
    required this.completionTokens,
    required this.latency,
  });

  int get totalTokens => promptTokens + completionTokens;
}

/// Configuration for an AI provider.
class AiProviderConfig {
  final String apiKey;
  final String model;
  final int maxTokens;
  final double temperature;
  final Duration timeout;
  final int maxRetries;
  final Duration retryDelay;

  const AiProviderConfig({
    required this.apiKey,
    required this.model,
    this.maxTokens = 2048,
    this.temperature = 0.3,
    this.timeout = const Duration(seconds: 60),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });
}

/// Exception thrown when an AI provider encounters an error.
class AiProviderException implements Exception {
  final String message;
  final int? statusCode;
  final String? providerName;

  const AiProviderException({
    required this.message,
    this.statusCode,
    this.providerName,
  });

  @override
  String toString() =>
      'AiProviderException(provider: $providerName, status: $statusCode): $message';
}

/// Abstract base class for all AI providers used in the testing framework.
///
/// Implement this class to integrate a new AI provider (e.g. OpenAI, Claude).
abstract class AiProviderAbstract {
  /// Human-readable name of the provider (e.g. "OpenAI", "Claude").
  String get providerName;

  /// Whether the provider is currently available and configured.
  bool get isAvailable;

  /// The configuration used by this provider instance.
  AiProviderConfig get config;

  /// Send a list of [messages] and receive a completion result.
  ///
  /// Throws [AiProviderException] on errors.
  Future<AiCompletionResult> complete(List<AiMessage> messages);

  /// Convenience method: send a single [prompt] as a user message.
  Future<AiCompletionResult> prompt(String prompt) =>
      complete([AiMessage(role: 'user', content: prompt)]);

  /// Test connectivity and authentication with the provider.
  ///
  /// Returns `true` if the provider is reachable and the API key is valid.
  Future<bool> testConnection();

  /// Release any resources held by this provider (e.g. HTTP clients).
  Future<void> dispose();
}
