import 'dart:convert';
import 'dart:io';

import 'test_analyzer.dart';
import 'bug_detector.dart';
import 'test_generator.dart';

/// Aggregated report produced by the AI testing framework.
class AiTestReport {
  final String appName;
  final DateTime generatedAt;
  final TestAnalysisResult? analysisResult;
  final BugDetectionResult? bugDetectionResult;
  final TestGenerationResult? generationResult;
  final Map<String, dynamic> metadata;

  const AiTestReport({
    required this.appName,
    required this.generatedAt,
    this.analysisResult,
    this.bugDetectionResult,
    this.generationResult,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'generatedAt': generatedAt.toIso8601String(),
        if (analysisResult != null)
          'analysisResult': analysisResult!.toJson(),
        if (bugDetectionResult != null)
          'bugDetectionResult': bugDetectionResult!.toJson(),
        if (generationResult != null)
          'generationResult': generationResult!.toJson(),
        'metadata': metadata,
      };
}

/// Generates HTML and JSON test reports from the AI testing framework results.
class ReportGenerator {
  final String appName;

  const ReportGenerator({this.appName = 'FileHive'});

  /// Write a JSON report to [outputPath].
  Future<void> generateJson(
    AiTestReport report, {
    required String outputPath,
  }) async {
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(report.toJson()));
  }

  /// Write an HTML report to [outputPath].
  Future<void> generateHtml(
    AiTestReport report, {
    required String outputPath,
  }) async {
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(_buildHtml(report));
  }

  String _buildHtml(AiTestReport report) {
    final analysis = report.analysisResult;
    final bugs = report.bugDetectionResult;
    final generated = report.generationResult;

    final issuesHtml = analysis?.issues
            .map((i) => '<li class="issue">$i</li>')
            .join('\n') ??
        '';
    final suggestionsHtml = analysis?.suggestions
            .map((s) => '<li class="suggestion">$s</li>')
            .join('\n') ??
        '';

    final bugsHtml = bugs?.bugs.map((b) {
          final sevClass = b.severity.name.toLowerCase();
          return '''
      <div class="bug $sevClass">
        <h4>[${b.severity.name.toUpperCase()}] ${b.title}</h4>
        <p>${b.description}</p>
        ${b.location != null ? '<p><strong>Location:</strong> ${b.location}</p>' : ''}
        ${b.suggestedFix != null ? '<p><strong>Fix:</strong> ${b.suggestedFix}</p>' : ''}
      </div>''';
        }).join('\n') ??
        '';

    final testsHtml = generated?.testCases.map((t) {
          return '''
      <div class="test-case">
        <h4>${t.name} <span class="badge">${t.category}</span></h4>
        <p>${t.description}</p>
        <pre><code>${_escapeHtml(t.dartCode)}</code></pre>
      </div>''';
        }).join('\n') ??
        '';

    return '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${report.appName} – AI Test Report</title>
  <style>
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
           margin: 0; padding: 2rem; background: #f5f5f7; color: #1d1d1f; }
    h1 { color: #0071e3; }
    h2 { border-bottom: 2px solid #0071e3; padding-bottom: .4rem; }
    .card { background: #fff; border-radius: 12px; padding: 1.5rem;
            margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,.08); }
    .badge { background: #0071e3; color: #fff; border-radius: 4px;
             padding: 2px 6px; font-size: .75rem; }
    .issue { color: #c00; }
    .suggestion { color: #006600; }
    .bug { padding: .8rem; border-radius: 8px; margin-bottom: .8rem; }
    .bug.critical { background: #fde8e8; border-left: 4px solid #c00; }
    .bug.high { background: #fff3e0; border-left: 4px solid #e65100; }
    .bug.medium { background: #fffde7; border-left: 4px solid #f9a825; }
    .bug.low, .bug.info { background: #e8f5e9; border-left: 4px solid #388e3c; }
    pre { background: #1e1e2e; color: #cdd6f4; padding: 1rem;
          border-radius: 8px; overflow-x: auto; font-size: .85rem; }
    .test-case { border: 1px solid #e0e0e0; border-radius: 8px;
                 padding: 1rem; margin-bottom: 1rem; }
    .meta { color: #888; font-size: .85rem; }
  </style>
</head>
<body>
  <h1>🤖 ${report.appName} – AI Test Report</h1>
  <p class="meta">Generated: ${report.generatedAt.toLocal()}</p>

  ${analysis != null ? '''
  <div class="card">
    <h2>📊 Test Analysis</h2>
    <p><strong>Summary:</strong> ${analysis.summary}</p>
    <p><strong>Confidence:</strong> ${(analysis.confidenceScore * 100).toStringAsFixed(1)}%
       &nbsp;|&nbsp; <strong>Provider:</strong> ${analysis.providerName}</p>
    ${issuesHtml.isNotEmpty ? '<h3>Issues</h3><ul>$issuesHtml</ul>' : ''}
    ${suggestionsHtml.isNotEmpty ? '<h3>Suggestions</h3><ul>$suggestionsHtml</ul>' : ''}
  </div>''' : ''}

  ${bugs != null ? '''
  <div class="card">
    <h2>🐛 Bug Detection (${bugs.bugs.length} found)</h2>
    <p><strong>Provider:</strong> ${bugs.providerName}
       &nbsp;|&nbsp; <strong>Critical:</strong> ${bugs.criticalCount}
       &nbsp;|&nbsp; <strong>High:</strong> ${bugs.highCount}</p>
    $bugsHtml
  </div>''' : ''}

  ${generated != null ? '''
  <div class="card">
    <h2>🧪 Generated Test Cases (${generated.testCases.length})</h2>
    <p><strong>Provider:</strong> ${generated.providerName}</p>
    $testsHtml
  </div>''' : ''}

</body>
</html>''';
  }

  String _escapeHtml(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
