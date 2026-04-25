import 'dart:convert';

import 'ai_provider_abstract.dart';

/// A single generated test case.
class GeneratedTestCase {
  final String name;
  final String description;
  final String dartCode;
  final String category;
  final List<String> tags;

  const GeneratedTestCase({
    required this.name,
    required this.description,
    required this.dartCode,
    required this.category,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'dartCode': dartCode,
        'category': category,
        'tags': tags,
      };
}

/// Result of a test-generation pass.
class TestGenerationResult {
  final List<GeneratedTestCase> testCases;
  final String providerName;
  final Duration generationLatency;

  const TestGenerationResult({
    required this.testCases,
    required this.providerName,
    required this.generationLatency,
  });

  Map<String, dynamic> toJson() => {
        'testCases': testCases.map((t) => t.toJson()).toList(),
        'providerName': providerName,
        'generationLatencyMs': generationLatency.inMilliseconds,
        'totalGenerated': testCases.length,
      };
}

/// Uses an AI provider to automatically generate comprehensive Flutter/Dart
/// test cases from source code, feature descriptions, or bug reports.
class TestGenerator {
  final AiProviderAbstract _provider;

  TestGenerator(this._provider);

  /// Generate unit/widget tests for the given [dartCode].
  ///
  /// [fileName] is used as context so the AI can produce correct imports.
  Future<TestGenerationResult> generateFromCode(
    String dartCode, {
    String? fileName,
    int maxTests = 5,
  }) async {
    final stopwatch = Stopwatch()..start();

    final systemPrompt = '''You are an expert Flutter/Dart test engineer.
Generate comprehensive test cases for the provided code.
Return a JSON object:
{
  "testCases": [
    {
      "name": "<test name>",
      "description": "<what is tested>",
      "dartCode": "<complete runnable test code>",
      "category": "<unit|widget|integration>",
      "tags": ["<tag1>", "<tag2>"]
    }
  ]
}
Each dartCode must be complete and self-contained (include imports).
Return ONLY valid JSON.''';

    final location = fileName != null ? ' from $fileName' : '';
    final userPrompt = '''Generate up to $maxTests tests$location for:

```dart
$dartCode
```''';

    final result = await _provider.complete([
      AiMessage(role: 'system', content: systemPrompt),
      AiMessage(role: 'user', content: userPrompt),
    ]);

    stopwatch.stop();
    return _parseResult(result.content, stopwatch.elapsed);
  }

  /// Generate tests based on a natural-language [featureDescription].
  Future<TestGenerationResult> generateFromDescription(
    String featureDescription, {
    int maxTests = 5,
  }) async {
    final stopwatch = Stopwatch()..start();

    final systemPrompt = '''You are an expert Flutter/Dart test engineer.
Generate comprehensive Flutter test cases from a feature description.
Return a JSON object:
{
  "testCases": [
    {
      "name": "<test name>",
      "description": "<what is tested>",
      "dartCode": "<complete runnable test code using flutter_test>",
      "category": "<unit|widget|integration>",
      "tags": ["<tag1>", "<tag2>"]
    }
  ]
}
Return ONLY valid JSON.''';

    final userPrompt =
        'Generate up to $maxTests tests for this feature:\n\n$featureDescription';

    final result = await _provider.complete([
      AiMessage(role: 'system', content: systemPrompt),
      AiMessage(role: 'user', content: userPrompt),
    ]);

    stopwatch.stop();
    return _parseResult(result.content, stopwatch.elapsed);
  }

  /// Generate accessibility-focused test cases for a widget description.
  Future<TestGenerationResult> generateAccessibilityTests(
    String widgetDescription, {
    int maxTests = 3,
  }) async {
    final stopwatch = Stopwatch()..start();

    final systemPrompt = '''You are an accessibility and Flutter expert.
Generate accessibility test cases for the described widget.
Focus on: semantic labels, contrast, touch targets, screen reader support.
Return a JSON object:
{
  "testCases": [
    {
      "name": "<test name>",
      "description": "<accessibility aspect tested>",
      "dartCode": "<complete runnable test code>",
      "category": "widget",
      "tags": ["accessibility", "<other tags>"]
    }
  ]
}
Return ONLY valid JSON.''';

    final userPrompt =
        'Generate up to $maxTests accessibility tests for:\n\n$widgetDescription';

    final result = await _provider.complete([
      AiMessage(role: 'system', content: systemPrompt),
      AiMessage(role: 'user', content: userPrompt),
    ]);

    stopwatch.stop();
    return _parseResult(result.content, stopwatch.elapsed);
  }

  TestGenerationResult _parseResult(String rawContent, Duration latency) {
    try {
      final cleaned = rawContent
          .replaceAll(RegExp(r'```(?:json)?\s*'), '')
          .replaceAll('```', '')
          .trim();
      final decoded = json.decode(cleaned) as Map<String, dynamic>;
      final casesJson = (decoded['testCases'] as List?) ?? [];

      final testCases = casesJson.map((t) {
        final map = t as Map<String, dynamic>;
        return GeneratedTestCase(
          name: map['name'] as String? ?? 'Unnamed test',
          description: map['description'] as String? ?? '',
          dartCode: map['dartCode'] as String? ?? '',
          category: map['category'] as String? ?? 'unit',
          tags: List<String>.from(
              (map['tags'] as List?)?.map((e) => e.toString()) ?? []),
        );
      }).toList();

      return TestGenerationResult(
        testCases: testCases,
        providerName: _provider.providerName,
        generationLatency: latency,
      );
    } catch (_) {
      return TestGenerationResult(
        testCases: const [],
        providerName: _provider.providerName,
        generationLatency: latency,
      );
    }
  }
}
