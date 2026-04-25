import 'dart:io';

import 'package:dio/dio.dart';

import 'ai_provider_abstract.dart';

/// OpenAI GPT provider implementation.
///
/// Reads the API key from the `OPENAI_API_KEY` environment variable when not
/// supplied explicitly via [AiProviderConfig].
class OpenAiProvider implements AiProviderAbstract {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _defaultModel = 'gpt-4';

  @override
  final AiProviderConfig config;

  late final Dio _dio;

  OpenAiProvider({AiProviderConfig? config})
      : config = config ??
            AiProviderConfig(
              apiKey: Platform.environment['OPENAI_API_KEY'] ?? '',
              model: _defaultModel,
            ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: this.config.timeout,
        receiveTimeout: this.config.timeout,
        headers: {
          'Authorization': 'Bearer ${this.config.apiKey}',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  @override
  String get providerName => 'OpenAI';

  @override
  bool get isAvailable => config.apiKey.isNotEmpty;

  @override
  Future<AiCompletionResult> complete(List<AiMessage> messages) async {
    if (!isAvailable) {
      throw AiProviderException(
        message: 'OpenAI API key is not configured. '
            'Set the OPENAI_API_KEY environment variable.',
        providerName: providerName,
      );
    }

    final stopwatch = Stopwatch()..start();
    int attempt = 0;

    while (true) {
      attempt++;
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/chat/completions',
          data: {
            'model': config.model,
            'messages': messages.map((m) => m.toJson()).toList(),
            'max_tokens': config.maxTokens,
            'temperature': config.temperature,
          },
        );

        stopwatch.stop();
        final data = response.data!;
        final choice = (data['choices'] as List).first as Map<String, dynamic>;
        final message = choice['message'] as Map<String, dynamic>;
        final usage = data['usage'] as Map<String, dynamic>;

        return AiCompletionResult(
          content: message['content'] as String,
          model: data['model'] as String,
          promptTokens: (usage['prompt_tokens'] as num).toInt(),
          completionTokens: (usage['completion_tokens'] as num).toInt(),
          latency: stopwatch.elapsed,
        );
      } on DioException catch (e) {
        if (attempt >= config.maxRetries || !_isRetryable(e)) {
          stopwatch.stop();
          throw AiProviderException(
            message: e.message ?? 'Unknown DioException',
            statusCode: e.response?.statusCode,
            providerName: providerName,
          );
        }
        await Future.delayed(config.retryDelay * attempt);
      }
    }
  }

  @override
  Future<AiCompletionResult> prompt(String text) =>
      complete([AiMessage(role: 'user', content: text)]);

  @override
  Future<bool> testConnection() async {
    try {
      final result = await prompt('Reply with exactly: OK');
      return result.content.isNotEmpty;
    } on AiProviderException {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    _dio.close();
  }

  bool _isRetryable(DioException e) {
    final status = e.response?.statusCode;
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        status == 429 ||
        (status != null && status >= 500);
  }
}
