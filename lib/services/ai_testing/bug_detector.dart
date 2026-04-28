import 'dart:convert';

import 'ai_provider_abstract.dart';

/// Severity level for a detected bug.
enum BugSeverity { critical, high, medium, low, info }

/// A single bug identified by the AI bug detector.
class DetectedBug {
  final String title;
  final String description;
  final BugSeverity severity;
  final String? location;
  final String? suggestedFix;
  final String? codeSnippet;

  const DetectedBug({
    required this.title,
    required this.description,
    required this.severity,
    this.location,
    this.suggestedFix,
    this.codeSnippet,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'severity': severity.name,
        if (location != null) 'location': location,
        if (suggestedFix != null) 'suggestedFix': suggestedFix,
        if (codeSnippet != null) 'codeSnippet': codeSnippet,
      };
}

/// Result of a bug-detection pass over a piece of code or test output.
class BugDetectionResult {
  final List<DetectedBug> bugs;
  final String providerName;
  final Duration detectionLatency;

  const BugDetectionResult({
    required this.bugs,
    required this.providerName,
    required this.detectionLatency,
  });

  int get criticalCount =>
      bugs.where((b) => b.severity == BugSeverity.critical).length;
  int get highCount =>
      bugs.where((b) => b.severity == BugSeverity.high).length;
  bool get hasCriticalBugs => criticalCount > 0;

  Map<String, dynamic> toJson() => {
        'bugs': bugs.map((b) => b.toJson()).toList(),
        'providerName': providerName,
        'detectionLatencyMs': detectionLatency.inMilliseconds,
        'summary': {
          'total': bugs.length,
          'critical': criticalCount,
          'high': highCount,
          'medium': bugs.where((b) => b.severity == BugSeverity.medium).length,
          'low': bugs.where((b) => b.severity == BugSeverity.low).length,
          'info': bugs.where((b) => b.severity == BugSeverity.info).length,
        },
      };
}

/// Uses an AI provider to detect potential bugs in Dart/Flutter source code
/// or test output logs.
class BugDetector {
  final AiProviderAbstract _provider;

  BugDetector(this._provider);

  /// Analyse [code] (Dart source) for potential bugs and return a
  /// [BugDetectionResult].
  Future<BugDetectionResult> analyzeCode(
    String code, {
    String? fileName,
  }) async {
    final stopwatch = Stopwatch()..start();

    final systemPrompt = '''You are an expert Flutter/Dart code reviewer.
Analyse the provided Dart/Flutter code for bugs, anti-patterns, and issues.
Return a JSON object with this structure:
{
  "bugs": [
    {
      "title": "<short title>",
      "description": "<detailed description>",
      "severity": "<critical|high|medium|low|info>",
      "location": "<file:line if known>",
      "suggestedFix": "<how to fix>",
      "codeSnippet": "<relevant code snippet>"
    }
  ]
}
Return ONLY valid JSON. No extra text.''';

    final location = fileName != null ? ' in $fileName' : '';
    final userPrompt = 'Find bugs in the following Dart/Flutter code$location:\n\n'
        '```dart\n$code\n```';

    final result = await _provider.complete([
      AiMessage(role: 'system', content: systemPrompt),
      AiMessage(role: 'user', content: userPrompt),
    ]);

    stopwatch.stop();
    return _parseResult(result.content, stopwatch.elapsed);
  }

  /// Analyse a test log [output] for runtime errors and suspicious patterns.
  Future<BugDetectionResult> analyzeTestOutput(String output) async {
    final stopwatch = Stopwatch()..start();

    final systemPrompt = '''You are an expert Flutter/Dart QA engineer.
Analyse the provided test output log for errors, warnings, and issues.
Return a JSON object with this structure:
{
  "bugs": [
    {
      "title": "<short title>",
      "description": "<detailed description>",
      "severity": "<critical|high|medium|low|info>",
      "location": "<test/file reference if identifiable>",
      "suggestedFix": "<how to fix>"
    }
  ]
}
Return ONLY valid JSON.''';

    final userPrompt = 'Analyse the following test output:\n\n$output';

    final result = await _provider.complete([
      AiMessage(role: 'system', content: systemPrompt),
      AiMessage(role: 'user', content: userPrompt),
    ]);

    stopwatch.stop();
    return _parseResult(result.content, stopwatch.elapsed);
  }

  BugDetectionResult _parseResult(String rawContent, Duration latency) {
    try {
      final cleaned = rawContent
          .replaceAll(RegExp(r'```(?:json)?\s*'), '')
          .replaceAll('```', '')
          .trim();
      final decoded = json.decode(cleaned) as Map<String, dynamic>;
      final bugsJson = (decoded['bugs'] as List?) ?? [];

      final bugs = bugsJson.map((b) {
        final map = b as Map<String, dynamic>;
        return DetectedBug(
          title: map['title'] as String? ?? 'Unknown bug',
          description: map['description'] as String? ?? '',
          severity: _parseSeverity(map['severity'] as String?),
          location: map['location'] as String?,
          suggestedFix: map['suggestedFix'] as String?,
          codeSnippet: map['codeSnippet'] as String?,
        );
      }).toList();

      return BugDetectionResult(
        bugs: bugs,
        providerName: _provider.providerName,
        detectionLatency: latency,
      );
    } catch (_) {
      return BugDetectionResult(
        bugs: const [],
        providerName: _provider.providerName,
        detectionLatency: latency,
      );
    }
  }

  BugSeverity _parseSeverity(String? value) {
    switch (value?.toLowerCase()) {
      case 'critical':
        return BugSeverity.critical;
      case 'high':
        return BugSeverity.high;
      case 'medium':
        return BugSeverity.medium;
      case 'low':
        return BugSeverity.low;
      default:
        return BugSeverity.info;
    }
  }
}
