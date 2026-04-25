import 'dart:io';

import 'package:dio/dio.dart';

import 'ai_provider_abstract.dart';

/// Anthropic Claude provider implementation.
///
/// Reads the API key from the `CLAUDE_API_KEY` environment variable when not
/// supplied explicitly via [AiProviderConfig].
class ClaudeProvider implements AiProviderAbstract {
  static const String _baseUrl = 'https://api.anthropic.com/v1';
  static const String _defaultModel = 'claude-3-5-sonnet-20241022';
  static const String _anthropicVersion = '2023-06-01';

  @override
  final AiProviderConfig config;

  late final Dio _dio;

  ClaudeProvider({AiProviderConfig? config})
      : config = config ??
            AiProviderConfig(
              apiKey: Platform.environment['CLAUDE_API_KEY'] ?? '',
              model: _defaultModel,
            ) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: this.config.timeout,
        receiveTimeout: this.config.timeout,
        headers: {
          'x-api-key': this.config.apiKey,
          'anthropic-version': _anthropicVersion,
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  @override
  String get providerName => 'Claude';

  @override
  bool get isAvailable => config.apiKey.isNotEmpty;

  @override
  Future<AiCompletionResult> complete(List<AiMessage> messages) async {
    if (!isAvailable) {
      throw AiProviderException(
        message: 'Claude API key is not configured. '
            'Set the CLAUDE_API_KEY environment variable.',
        providerName: providerName,
      );
    }

    // Claude separates the system message from the conversation messages.
    String? systemPrompt;
    final conversationMessages = <AiMessage>[];

    for (final msg in messages) {
      if (msg.role == 'system') {
        systemPrompt = msg.content;
      } else {
        conversationMessages.add(msg);
      }
    }

    final stopwatch = Stopwatch()..start();
    int attempt = 0;

    while (true) {
      attempt++;
      try {
        final body = <String, dynamic>{
          'model': config.model,
          'max_tokens': config.maxTokens,
          'messages': conversationMessages.map((m) => m.toJson()).toList(),
        };
        if (systemPrompt != null) {
          body['system'] = systemPrompt;
        }

        final response = await _dio.post<Map<String, dynamic>>(
          '/messages',
          data: body,
        );

        stopwatch.stop();
        final data = response.data!;
        final contentList = data['content'] as List;
        final firstContent =
            contentList.firstWhere((c) => (c as Map)['type'] == 'text')
                as Map<String, dynamic>;
        final usage = data['usage'] as Map<String, dynamic>;

        return AiCompletionResult(
          content: firstContent['text'] as String,
          model: data['model'] as String,
          promptTokens: (usage['input_tokens'] as num).toInt(),
          completionTokens: (usage['output_tokens'] as num).toInt(),
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
