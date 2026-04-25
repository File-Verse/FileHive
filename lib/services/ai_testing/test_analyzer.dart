import 'dart:convert';

import 'ai_provider_abstract.dart';

/// Result of analysing a test run with an AI provider.
class TestAnalysisResult {
  final String summary;
  final List<String> issues;
  final List<String> suggestions;
  final double confidenceScore;
  final String providerName;
  final Duration analysisLatency;

  const TestAnalysisResult({
    required this.summary,
    required this.issues,
    required this.suggestions,
    required this.confidenceScore,
    required this.providerName,
    required this.analysisLatency,
  });

  bool get hasCriticalIssues =>
      issues.any((i) => i.toLowerCase().contains('critical'));

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'issues': issues,
        'suggestions': suggestions,
        'confidenceScore': confidenceScore,
        'providerName': providerName,
        'analysisLatencyMs': analysisLatency.inMilliseconds,
      };
}

/// Raw data about a single test execution that is passed to the analyser.
class TestExecutionData {
  final String testName;
  final bool passed;
  final Duration duration;
  final String? errorMessage;
  final String? stackTrace;
  final Map<String, dynamic> metadata;

  const TestExecutionData({
    required this.testName,
    required this.passed,
    required this.duration,
    this.errorMessage,
    this.stackTrace,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'testName': testName,
        'passed': passed,
        'durationMs': duration.inMilliseconds,
        if (errorMessage != null) 'errorMessage': errorMessage,
        if (stackTrace != null) 'stackTrace': stackTrace,
        'metadata': metadata,
      };
}

/// Analyses test results using an AI provider and returns actionable insights.
class TestAnalyzer {
  final AiProviderAbstract _provider;

  TestAnalyzer(this._provider);

  /// Analyse a list of [executions] and return a structured [TestAnalysisResult].
  Future<TestAnalysisResult> analyze(List<TestExecutionData> executions) async {
    final stopwatch = Stopwatch()..start();

    final passed = executions.where((e) => e.passed).length;
    final failed = executions.where((e) => !e.passed).length;
    final executionsJson = json.encode(executions.map((e) => e.toJson()).toList());

    final systemPrompt = '''You are an expert Flutter/Dart test analyser.
Analyse the provided test execution data and return a JSON object with these exact fields:
{
  "summary": "<brief overall summary>",
  "issues": ["<issue 1>", "<issue 2>"],
  "suggestions": ["<suggestion 1>", "<suggestion 2>"],
  "confidenceScore": <0.0-1.0>
}
Be concise. Focus on patterns, root causes, and actionable fixes.''';

    final userPrompt = '''Test run results:
- Total tests: ${executions.length}
- Passed: $passed
- Failed: $failed

Execution details:
$executionsJson

Provide analysis as valid JSON only.''';

    final result = await _provider.complete([
      AiMessage(role: 'system', content: systemPrompt),
      AiMessage(role: 'user', content: userPrompt),
    ]);

    stopwatch.stop();

    return _parseAnalysisResult(
      result.content,
      _provider.providerName,
      stopwatch.elapsed,
    );
  }

  /// Analyse a single [execution] in isolation.
  Future<TestAnalysisResult> analyzeSingle(TestExecutionData execution) =>
      analyze([execution]);

  TestAnalysisResult _parseAnalysisResult(
    String rawContent,
    String providerName,
    Duration latency,
  ) {
    try {
      // Strip markdown code fences if present.
      final cleaned = rawContent
          .replaceAll(RegExp(r'```(?:json)?\s*'), '')
          .replaceAll('```', '')
          .trim();
      final decoded = json.decode(cleaned) as Map<String, dynamic>;

      return TestAnalysisResult(
        summary: decoded['summary'] as String? ?? 'No summary provided',
        issues: List<String>.from(
            (decoded['issues'] as List?)?.map((e) => e.toString()) ?? []),
        suggestions: List<String>.from(
            (decoded['suggestions'] as List?)?.map((e) => e.toString()) ?? []),
        confidenceScore:
            (decoded['confidenceScore'] as num?)?.toDouble() ?? 0.5,
        providerName: providerName,
        analysisLatency: latency,
      );
    } catch (_) {
      return TestAnalysisResult(
        summary: rawContent,
        issues: const [],
        suggestions: const [],
        confidenceScore: 0.5,
        providerName: providerName,
        analysisLatency: latency,
      );
    }
  }
}
