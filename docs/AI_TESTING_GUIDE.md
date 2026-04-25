# AI Testing Guide – FileHive

This guide covers the setup, configuration, and usage of the AI-powered testing
framework built into the FileHive Flutter application.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Running Tests](#running-tests)
6. [CI/CD Integration](#cicd-integration)
7. [Troubleshooting](#troubleshooting)

---

## Overview

The AI testing framework adds three layers of intelligent testing on top of
Flutter's standard test runner:

| Layer | Class | Description |
|-------|-------|-------------|
| **Test Analysis** | `TestAnalyzer` | Analyses test results and identifies patterns |
| **Bug Detection** | `BugDetector` | Scans Dart/Flutter source for potential bugs |
| **Test Generation** | `TestGenerator` | Generates new test cases from code or descriptions |

Both **OpenAI GPT-4** and **Anthropic Claude** are supported. The framework
provides mock providers for offline testing so no API keys are needed for the
standard CI pipeline.

---

## Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- (Optional) OpenAI API key – for live OpenAI analysis
- (Optional) Anthropic API key – for live Claude analysis

---

## Installation

The framework is already included in the FileHive repository. Run:

```bash
flutter pub get
```

---

## Configuration

### Environment variables

Copy `config/.env.example` to `config/.env` and fill in your API keys:

```bash
cp config/.env.example config/.env
```

```dotenv
OPENAI_API_KEY=sk-...
CLAUDE_API_KEY=sk-ant-...
AI_PROVIDER=auto   # openai | claude | auto
```

> **Important**: Never commit `.env` to version control.

### `config/ai_config.yaml`

Fine-tune provider settings, test generation limits, bug-detection thresholds,
and report output directories in `config/ai_config.yaml`.

Key settings:

```yaml
active_provider: auto          # openai | claude | auto

openai:
  model: gpt-4
  max_tokens: 2048
  temperature: 0.3

bug_detection:
  minimum_severity: low
  fail_on_critical: true

reporting:
  output_directory: build/ai_test_reports
  formats: [json, html]
```

---

## Running Tests

### Standard tests (no API keys needed)

```bash
# Run all tests including AI integration tests with mock providers
flutter test

# Run only the AI integration tests
flutter test test/ai_integration/

# Run existing service tests
flutter test test/services/
```

### Live AI analysis

Set `OPENAI_API_KEY` and/or `CLAUDE_API_KEY` in your environment, then:

```bash
export OPENAI_API_KEY=sk-...
export CLAUDE_API_KEY=sk-ant-...
flutter test test/ai_integration/
```

---

## Using the Framework in Your Tests

### Test Analysis

```dart
import 'package:filehive/services/ai_testing/test_analyzer.dart';
import 'package:filehive/services/ai_testing/openai_provider.dart';

final provider = OpenAiProvider();
final analyzer = TestAnalyzer(provider);

final executions = [
  TestExecutionData(
    testName: 'my test',
    passed: false,
    duration: Duration(milliseconds: 50),
    errorMessage: 'Expected: true  Actual: false',
  ),
];

final result = await analyzer.analyze(executions);
print(result.summary);
print(result.suggestions);
```

### Bug Detection

```dart
import 'package:filehive/services/ai_testing/bug_detector.dart';
import 'package:filehive/services/ai_testing/claude_provider.dart';

final provider = ClaudeProvider();
final detector = BugDetector(provider);

final code = File('lib/services/transfer/send_service.dart').readAsStringSync();
final result = await detector.analyzeCode(code, fileName: 'send_service.dart');

for (final bug in result.bugs) {
  print('[${bug.severity.name}] ${bug.title}');
  print('  ${bug.description}');
}
```

### Test Generation

```dart
import 'package:filehive/services/ai_testing/test_generator.dart';
import 'package:filehive/services/ai_testing/openai_provider.dart';

final provider = OpenAiProvider();
final generator = TestGenerator(provider);

final code = File('lib/services/network/mdns_service.dart').readAsStringSync();
final result = await generator.generateFromCode(code, maxTests: 5);

for (final testCase in result.testCases) {
  print('// ${testCase.name}');
  print(testCase.dartCode);
}
```

### Report Generation

```dart
import 'package:filehive/services/ai_testing/report_generator.dart';

final reporter = ReportGenerator(appName: 'FileHive');
final report = AiTestReport(
  appName: 'FileHive',
  generatedAt: DateTime.now(),
  analysisResult: analysisResult,
  bugDetectionResult: bugResult,
  generationResult: genResult,
);

await reporter.generateJson(report, outputPath: 'build/ai_test_reports/report.json');
await reporter.generateHtml(report, outputPath: 'build/ai_test_reports/report.html');
```

---

## CI/CD Integration

The `.github/workflows/ai_testing.yml` workflow:

- Runs on every push and pull request (using mock providers – no API keys needed)
- Runs nightly with live AI providers when `OPENAI_API_KEY` / `CLAUDE_API_KEY`
  secrets are configured in the repository
- Uploads HTML and JSON reports as workflow artifacts

### Setting up secrets

In your GitHub repository go to **Settings → Secrets and variables → Actions**
and add:

| Secret name | Value |
|-------------|-------|
| `OPENAI_API_KEY` | Your OpenAI API key |
| `CLAUDE_API_KEY` | Your Anthropic API key |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `AiProviderException: API key not configured` | Set `OPENAI_API_KEY` or `CLAUDE_API_KEY` env variable |
| `DioException: connection timeout` | Increase `timeout_seconds` in `ai_config.yaml` |
| Provider returns non-JSON response | The framework falls back to using the raw text as the summary |
| Tests fail with rate limit errors | Increase `retry_delay_seconds` or reduce test parallelism |
