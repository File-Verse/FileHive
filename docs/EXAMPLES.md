# Usage Examples – AI Testing Framework

These examples show common patterns for using the AI testing framework in
FileHive.  All examples can run with mock providers (no API keys needed) or
live AI providers.

---

## 1. Quick start with mock providers

```dart
import 'package:filehive/services/ai_testing/test_analyzer.dart';
import 'test/ai_integration/mock_providers.dart';

void main() async {
  final analyzer = TestAnalyzer(MockAnalysisProvider());

  final result = await analyzer.analyze([
    const TestExecutionData(
      testName: 'server starts',
      passed: true,
      duration: Duration(milliseconds: 40),
    ),
    const TestExecutionData(
      testName: 'sendMessage throws on null socket',
      passed: false,
      duration: Duration(milliseconds: 5),
      errorMessage: 'Null check operator used on a null value',
    ),
  ]);

  print('Summary: ${result.summary}');
  print('Confidence: ${(result.confidenceScore * 100).toStringAsFixed(0)}%');
  for (final issue in result.issues) {
    print('  ⚠ $issue');
  }
}
```

---

## 2. Switch between OpenAI and Claude via environment variable

```dart
import 'dart:io';
import 'package:filehive/services/ai_testing/ai_provider_abstract.dart';
import 'package:filehive/services/ai_testing/openai_provider.dart';
import 'package:filehive/services/ai_testing/claude_provider.dart';
import 'package:filehive/services/ai_testing/test_analyzer.dart';

AiProviderAbstract createProvider() {
  final choice = Platform.environment['AI_PROVIDER'] ?? 'openai';
  switch (choice) {
    case 'claude':
      return ClaudeProvider();
    case 'openai':
    default:
      return OpenAiProvider();
  }
}

void main() async {
  final provider = createProvider();
  print('Using provider: ${provider.providerName}');

  if (!await provider.testConnection()) {
    print('Provider unavailable – check your API key.');
    return;
  }

  final analyzer = TestAnalyzer(provider);
  // ... run analysis
  await provider.dispose();
}
```

---

## 3. Scan a service file for bugs

```dart
import 'dart:io';
import 'package:filehive/services/ai_testing/bug_detector.dart';
import 'package:filehive/services/ai_testing/openai_provider.dart';

void main() async {
  final provider = OpenAiProvider();
  final detector = BugDetector(provider);

  final file = File('lib/services/transfer/send_service.dart');
  final result = await detector.analyzeCode(
    file.readAsStringSync(),
    fileName: file.path,
  );

  print('Bugs found: ${result.bugs.length}');
  print('Critical: ${result.criticalCount}  High: ${result.highCount}');

  for (final bug in result.bugs) {
    print('\n[${bug.severity.name.toUpperCase()}] ${bug.title}');
    if (bug.location != null) print('  at ${bug.location}');
    print('  ${bug.description}');
    if (bug.suggestedFix != null) print('  Fix: ${bug.suggestedFix}');
  }

  await provider.dispose();
}
```

---

## 4. Auto-generate tests for a feature

```dart
import 'package:filehive/services/ai_testing/test_generator.dart';
import 'package:filehive/services/ai_testing/claude_provider.dart';

void main() async {
  final provider = ClaudeProvider();
  final generator = TestGenerator(provider);

  final result = await generator.generateFromDescription(
    '''
    The mDNS service registers this device as "_filehive._tcp" on the local
    network and scans for other FileHive devices.  It exposes a stream of
    discovered devices updated in real time.
    ''',
    maxTests: 5,
  );

  print('Generated ${result.testCases.length} tests\n');
  for (final testCase in result.testCases) {
    print('// Test: ${testCase.name}  [${testCase.category}]');
    print(testCase.dartCode);
    print('---');
  }

  await provider.dispose();
}
```

---

## 5. Generate an HTML + JSON report

```dart
import 'package:filehive/services/ai_testing/report_generator.dart';
import 'package:filehive/services/ai_testing/test_analyzer.dart';
import 'package:filehive/services/ai_testing/bug_detector.dart';
import 'package:filehive/services/ai_testing/test_generator.dart';
import 'package:filehive/services/ai_testing/openai_provider.dart';

void main() async {
  final provider = OpenAiProvider();

  final analysisResult = await TestAnalyzer(provider).analyze([
    const TestExecutionData(
      testName: 'transfer completes',
      passed: true,
      duration: Duration(seconds: 2),
    ),
  ]);

  final report = AiTestReport(
    appName: 'FileHive',
    generatedAt: DateTime.now(),
    analysisResult: analysisResult,
  );

  final reporter = const ReportGenerator(appName: 'FileHive');
  await reporter.generateJson(report, outputPath: 'build/ai_test_reports/report.json');
  await reporter.generateHtml(report, outputPath: 'build/ai_test_reports/report.html');

  print('Reports written to build/ai_test_reports/');
  await provider.dispose();
}
```

---

## 6. Fallback from OpenAI to Claude

```dart
import 'package:filehive/services/ai_testing/ai_provider_abstract.dart';
import 'package:filehive/services/ai_testing/openai_provider.dart';
import 'package:filehive/services/ai_testing/claude_provider.dart';
import 'package:filehive/services/ai_testing/test_analyzer.dart';

Future<AiProviderAbstract> resolveProvider() async {
  final openai = OpenAiProvider();
  if (openai.isAvailable && await openai.testConnection()) {
    return openai;
  }
  print('OpenAI unavailable, falling back to Claude.');
  return ClaudeProvider();
}

void main() async {
  final provider = await resolveProvider();
  final analyzer = TestAnalyzer(provider);
  // ... run analysis
  await provider.dispose();
}
```

---

## 7. Running from CI with mock providers (no API keys)

```bash
# In .github/workflows/ai_testing.yml this is the default path:
flutter test test/ai_integration/ --reporter=expanded
```

All tests in `test/ai_integration/ai_testing_integration_test.dart` use mock
providers and will pass without any API keys configured.
