# API Reference – AI Testing Framework

## Classes

---

### `AiProviderAbstract`

Abstract base class for all AI providers.

**Location**: `lib/services/ai_testing/ai_provider_abstract.dart`

| Member | Type | Description |
|--------|------|-------------|
| `providerName` | `String` (getter) | Human-readable provider name |
| `isAvailable` | `bool` (getter) | Whether the provider is configured and ready |
| `config` | `AiProviderConfig` (getter) | Provider configuration |
| `complete(messages)` | `Future<AiCompletionResult>` | Send messages and receive a completion |
| `prompt(text)` | `Future<AiCompletionResult>` | Convenience single-turn prompt |
| `testConnection()` | `Future<bool>` | Verify API key and connectivity |
| `dispose()` | `Future<void>` | Release resources |

---

### `AiProviderConfig`

Configuration data class for provider instances.

```dart
AiProviderConfig({
  required String apiKey,
  required String model,
  int maxTokens = 2048,
  double temperature = 0.3,
  Duration timeout = const Duration(seconds: 60),
  int maxRetries = 3,
  Duration retryDelay = const Duration(seconds: 2),
})
```

---

### `AiMessage`

Represents a single message in a conversation.

```dart
AiMessage({required String role, required String content})
```

`role` is typically `'system'`, `'user'`, or `'assistant'`.

---

### `AiCompletionResult`

Result of a provider completion call.

| Field | Type | Description |
|-------|------|-------------|
| `content` | `String` | The generated text |
| `model` | `String` | Model identifier returned by the provider |
| `promptTokens` | `int` | Number of tokens in the prompt |
| `completionTokens` | `int` | Number of tokens in the completion |
| `totalTokens` | `int` | Sum of prompt + completion tokens |
| `latency` | `Duration` | Round-trip latency |

---

### `AiProviderException`

Thrown when a provider encounters a non-retryable error.

```dart
AiProviderException({
  required String message,
  int? statusCode,
  String? providerName,
})
```

---

### `OpenAiProvider`

OpenAI GPT implementation of `AiProviderAbstract`.

```dart
OpenAiProvider({AiProviderConfig? config})
```

Reads `OPENAI_API_KEY` from the environment when `config` is omitted.

---

### `ClaudeProvider`

Anthropic Claude implementation of `AiProviderAbstract`.

```dart
ClaudeProvider({AiProviderConfig? config})
```

Reads `CLAUDE_API_KEY` from the environment when `config` is omitted.

---

### `TestAnalyzer`

Analyses test execution results with an AI provider.

```dart
TestAnalyzer(AiProviderAbstract provider)
```

| Method | Returns | Description |
|--------|---------|-------------|
| `analyze(executions)` | `Future<TestAnalysisResult>` | Analyse a list of test executions |
| `analyzeSingle(execution)` | `Future<TestAnalysisResult>` | Analyse a single execution |

#### `TestExecutionData`

```dart
TestExecutionData({
  required String testName,
  required bool passed,
  required Duration duration,
  String? errorMessage,
  String? stackTrace,
  Map<String, dynamic> metadata = const {},
})
```

#### `TestAnalysisResult`

| Field | Type | Description |
|-------|------|-------------|
| `summary` | `String` | Overall summary |
| `issues` | `List<String>` | Identified issues |
| `suggestions` | `List<String>` | Actionable suggestions |
| `confidenceScore` | `double` | 0.0–1.0 confidence |
| `providerName` | `String` | Provider used |
| `analysisLatency` | `Duration` | Time taken |
| `hasCriticalIssues` | `bool` | True if any issue contains "critical" |

---

### `BugDetector`

Detects bugs in Dart/Flutter code using an AI provider.

```dart
BugDetector(AiProviderAbstract provider)
```

| Method | Returns | Description |
|--------|---------|-------------|
| `analyzeCode(code, {fileName})` | `Future<BugDetectionResult>` | Scan Dart source code |
| `analyzeTestOutput(output)` | `Future<BugDetectionResult>` | Analyse test log output |

#### `DetectedBug`

| Field | Type | Description |
|-------|------|-------------|
| `title` | `String` | Short title |
| `description` | `String` | Detailed description |
| `severity` | `BugSeverity` | `critical \| high \| medium \| low \| info` |
| `location` | `String?` | File/line reference |
| `suggestedFix` | `String?` | How to fix |
| `codeSnippet` | `String?` | Relevant code |

#### `BugDetectionResult`

| Field | Type | Description |
|-------|------|-------------|
| `bugs` | `List<DetectedBug>` | All detected bugs |
| `criticalCount` | `int` | Number of critical bugs |
| `highCount` | `int` | Number of high-severity bugs |
| `hasCriticalBugs` | `bool` | True if `criticalCount > 0` |

---

### `TestGenerator`

Generates Dart/Flutter test cases using an AI provider.

```dart
TestGenerator(AiProviderAbstract provider)
```

| Method | Returns | Description |
|--------|---------|-------------|
| `generateFromCode(code, {fileName, maxTests})` | `Future<TestGenerationResult>` | Generate tests from source |
| `generateFromDescription(description, {maxTests})` | `Future<TestGenerationResult>` | Generate from feature description |
| `generateAccessibilityTests(description, {maxTests})` | `Future<TestGenerationResult>` | Generate accessibility tests |

#### `GeneratedTestCase`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `String` | Test name |
| `description` | `String` | What is tested |
| `dartCode` | `String` | Complete runnable test code |
| `category` | `String` | `unit \| widget \| integration` |
| `tags` | `List<String>` | Descriptive tags |

---

### `ReportGenerator`

Generates HTML and JSON reports.

```dart
ReportGenerator({String appName = 'FileHive'})
```

| Method | Returns | Description |
|--------|---------|-------------|
| `generateJson(report, {outputPath})` | `Future<void>` | Write JSON report |
| `generateHtml(report, {outputPath})` | `Future<void>` | Write HTML report |

#### `AiTestReport`

```dart
AiTestReport({
  required String appName,
  required DateTime generatedAt,
  TestAnalysisResult? analysisResult,
  BugDetectionResult? bugDetectionResult,
  TestGenerationResult? generationResult,
  Map<String, dynamic> metadata = const {},
})
```
