import 'dart:async';

import 'package:filehive/services/ai_testing/ai_provider_abstract.dart';

/// Mock AI provider for use in tests – no real HTTP calls are made.
class MockAiProvider implements AiProviderAbstract {
  @override
  final String providerName;

  @override
  bool isAvailable;

  @override
  final AiProviderConfig config;

  /// Responses to return in order; cycles back to the last element when
  /// the list is exhausted.
  final List<String> responses;

  int _callCount = 0;
  bool _disposed = false;

  /// If set to a non-null value, [complete] will throw this exception
  /// instead of returning a response.
  AiProviderException? errorToThrow;

  MockAiProvider({
    this.providerName = 'MockProvider',
    this.isAvailable = true,
    AiProviderConfig? config,
    List<String>? responses,
  })  : config = config ??
            const AiProviderConfig(apiKey: 'mock-key', model: 'mock-model'),
        responses = responses ?? const ['{"summary":"ok","issues":[],"suggestions":[],"confidenceScore":0.9}'];

  @override
  Future<AiCompletionResult> complete(List<AiMessage> messages) async {
    if (errorToThrow != null) throw errorToThrow!;

    final index = _callCount < responses.length
        ? _callCount
        : responses.length - 1;
    _callCount++;

    return AiCompletionResult(
      content: responses[index],
      model: config.model,
      promptTokens: 50,
      completionTokens: 30,
      latency: const Duration(milliseconds: 10),
    );
  }

  @override
  Future<AiCompletionResult> prompt(String text) =>
      complete([AiMessage(role: 'user', content: text)]);

  @override
  Future<bool> testConnection() async => isAvailable;

  @override
  Future<void> dispose() async {
    _disposed = true;
  }

  /// Total number of [complete] calls made.
  int get callCount => _callCount;

  /// Whether [dispose] has been called.
  bool get isDisposed => _disposed;

  /// Reset call counter and disposed state.
  void reset() {
    _callCount = 0;
    _disposed = false;
    errorToThrow = null;
  }
}

/// A mock provider that always returns analysis-shaped JSON.
class MockAnalysisProvider extends MockAiProvider {
  MockAnalysisProvider()
      : super(
          providerName: 'MockAnalysisProvider',
          responses: const [
            '{"summary":"All tests passed with minor warnings",'
                '"issues":["Potential null reference in transfer service"],'
                '"suggestions":["Add null checks before accessing socket"],'
                '"confidenceScore":0.88}',
          ],
        );
}

/// A mock provider that always returns bug-detection-shaped JSON.
class MockBugDetectionProvider extends MockAiProvider {
  MockBugDetectionProvider()
      : super(
          providerName: 'MockBugDetectionProvider',
          responses: const [
            '{"bugs":['
                '{"title":"Unchecked null socket","description":"socket may be null when sendMessage is called",'
                '"severity":"high","location":"lib/main.dart:79","suggestedFix":"Guard with null check"}'
                ']}',
          ],
        );
}

/// A mock provider that always returns test-generation-shaped JSON.
class MockTestGenerationProvider extends MockAiProvider {
  MockTestGenerationProvider()
      : super(
          providerName: 'MockTestGenerationProvider',
          responses: const [
            '{"testCases":['
                '{"name":"startServer starts server successfully","description":"Verify server socket binds",'
                '"dartCode":"import \'package:flutter_test/flutter_test.dart\';\nvoid main(){test(\'server starts\',(){expect(true,isTrue);});}","category":"unit","tags":["server","network"]}'
                ']}',
          ],
        );
}

/// A mock provider that simulates a provider that is unavailable.
class MockUnavailableProvider extends MockAiProvider {
  MockUnavailableProvider()
      : super(
          providerName: 'MockUnavailableProvider',
          isAvailable: false,
        );

  @override
  Future<AiCompletionResult> complete(List<AiMessage> messages) async {
    throw AiProviderException(
      message: 'Provider is unavailable',
      providerName: providerName,
    );
  }
}
