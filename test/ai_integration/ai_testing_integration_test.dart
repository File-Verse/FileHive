import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:filehive/services/ai_testing/ai_provider_abstract.dart';
import 'package:filehive/services/ai_testing/test_analyzer.dart';
import 'package:filehive/services/ai_testing/bug_detector.dart';
import 'package:filehive/services/ai_testing/test_generator.dart';
import 'package:filehive/services/ai_testing/report_generator.dart';

import 'mock_providers.dart';
import 'test_scenarios.dart';

void main() {
  // ---------------------------------------------------------------------------
  // MockAiProvider
  // ---------------------------------------------------------------------------
  group('MockAiProvider', () {
    test('returns configured responses', () async {
      final provider = MockAiProvider(responses: const ['hello']);
      final result = await provider.prompt('test');
      expect(result.content, equals('hello'));
    });

    test('increments call count', () async {
      final provider = MockAiProvider(responses: const ['a', 'b']);
      await provider.prompt('1');
      await provider.prompt('2');
      expect(provider.callCount, equals(2));
    });

    test('cycles on last response when list is exhausted', () async {
      final provider = MockAiProvider(responses: const ['first', 'last']);
      await provider.prompt('1');
      await provider.prompt('2');
      final result = await provider.prompt('3');
      expect(result.content, equals('last'));
    });

    test('throws configured error', () async {
      final provider = MockAiProvider();
      provider.errorToThrow = const AiProviderException(
        message: 'forced error',
        providerName: 'MockProvider',
      );
      expect(
        () => provider.prompt('test'),
        throwsA(isA<AiProviderException>()),
      );
    });

    test('testConnection returns isAvailable', () async {
      final available = MockAiProvider(isAvailable: true);
      final unavailable = MockUnavailableProvider();
      expect(await available.testConnection(), isTrue);
      expect(await unavailable.testConnection(), isFalse);
    });

    test('dispose sets isDisposed', () async {
      final provider = MockAiProvider();
      await provider.dispose();
      expect(provider.isDisposed, isTrue);
    });

    test('reset clears state', () async {
      final provider = MockAiProvider();
      await provider.prompt('x');
      await provider.dispose();
      provider.reset();
      expect(provider.callCount, equals(0));
      expect(provider.isDisposed, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // TestAnalyzer
  // ---------------------------------------------------------------------------
  group('TestAnalyzer', () {
    late MockAnalysisProvider provider;
    late TestAnalyzer analyzer;

    setUp(() {
      provider = MockAnalysisProvider();
      analyzer = TestAnalyzer(provider);
    });

    test('analyze returns TestAnalysisResult', () async {
      final result = await analyzer.analyze(TestScenarios.mixedExecutions());
      expect(result, isA<TestAnalysisResult>());
      expect(result.summary, isNotEmpty);
    });

    test('analyze result has valid confidence score', () async {
      final result = await analyzer.analyze(TestScenarios.mixedExecutions());
      expect(result.confidenceScore, greaterThanOrEqualTo(0.0));
      expect(result.confidenceScore, lessThanOrEqualTo(1.0));
    });

    test('analyze result contains provider name', () async {
      final result = await analyzer.analyze(TestScenarios.mixedExecutions());
      expect(result.providerName, equals(provider.providerName));
    });

    test('analyzeSingle delegates to analyze', () async {
      final exec = TestScenarios.mixedExecutions().first;
      final result = await analyzer.analyzeSingle(exec);
      expect(result, isA<TestAnalysisResult>());
    });

    test('analyze calls provider exactly once', () async {
      await analyzer.analyze(TestScenarios.allPassingExecutions());
      expect(provider.callCount, equals(1));
    });

    test('hasCriticalIssues is false when no critical issues', () async {
      final result =
          await analyzer.analyze(TestScenarios.allPassingExecutions());
      expect(result.hasCriticalIssues, isFalse);
    });

    test('toJson includes required keys', () async {
      final result = await analyzer.analyze(TestScenarios.mixedExecutions());
      final json = result.toJson();
      expect(json.containsKey('summary'), isTrue);
      expect(json.containsKey('issues'), isTrue);
      expect(json.containsKey('suggestions'), isTrue);
      expect(json.containsKey('confidenceScore'), isTrue);
    });

    test('handles malformed provider response gracefully', () async {
      final badProvider =
          MockAiProvider(responses: const ['not valid json }{']);
      final analyzerBad = TestAnalyzer(badProvider);
      final result =
          await analyzerBad.analyze(TestScenarios.allPassingExecutions());
      expect(result, isA<TestAnalysisResult>());
      expect(result.summary, isNotEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // BugDetector
  // ---------------------------------------------------------------------------
  group('BugDetector', () {
    late MockBugDetectionProvider provider;
    late BugDetector detector;

    setUp(() {
      provider = MockBugDetectionProvider();
      detector = BugDetector(provider);
    });

    test('analyzeCode returns BugDetectionResult', () async {
      final result =
          await detector.analyzeCode(TestScenarios.fileHiveMainSnippet);
      expect(result, isA<BugDetectionResult>());
    });

    test('analyzeCode detects bugs', () async {
      final result =
          await detector.analyzeCode(TestScenarios.fileHiveMainSnippet);
      expect(result.bugs, isNotEmpty);
    });

    test('detected bug has required fields', () async {
      final result =
          await detector.analyzeCode(TestScenarios.fileHiveMainSnippet);
      final bug = result.bugs.first;
      expect(bug.title, isNotEmpty);
      expect(bug.description, isNotEmpty);
    });

    test('analyzeCode includes provider name', () async {
      final result =
          await detector.analyzeCode(TestScenarios.fileHiveMainSnippet);
      expect(result.providerName, equals(provider.providerName));
    });

    test('analyzeTestOutput returns result', () async {
      final result = await detector
          .analyzeTestOutput(TestScenarios.failingTestOutputLog);
      expect(result, isA<BugDetectionResult>());
    });

    test('toJson includes bugs and summary', () async {
      final result =
          await detector.analyzeCode(TestScenarios.fileHiveMainSnippet);
      final json = result.toJson();
      expect(json.containsKey('bugs'), isTrue);
      expect(json.containsKey('summary'), isTrue);
    });

    test('handles empty bug list gracefully', () async {
      final cleanProvider =
          MockAiProvider(responses: const ['{"bugs":[]}']);
      final cleanDetector = BugDetector(cleanProvider);
      final result =
          await cleanDetector.analyzeCode(TestScenarios.cleanDartCode);
      expect(result.bugs, isEmpty);
      expect(result.hasCriticalBugs, isFalse);
    });

    test('hasCriticalBugs is false when no critical bugs in mock', () async {
      final result =
          await detector.analyzeCode(TestScenarios.fileHiveMainSnippet);
      // Mock returns "high" severity, not "critical"
      expect(result.hasCriticalBugs, isFalse);
      expect(result.highCount, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // TestGenerator
  // ---------------------------------------------------------------------------
  group('TestGenerator', () {
    late MockTestGenerationProvider provider;
    late TestGenerator generator;

    setUp(() {
      provider = MockTestGenerationProvider();
      generator = TestGenerator(provider);
    });

    test('generateFromCode returns TestGenerationResult', () async {
      final result = await generator.generateFromCode(
        TestScenarios.fileHiveMainSnippet,
        fileName: 'lib/main.dart',
      );
      expect(result, isA<TestGenerationResult>());
    });

    test('generateFromCode produces test cases', () async {
      final result = await generator.generateFromCode(
        TestScenarios.fileHiveMainSnippet,
      );
      expect(result.testCases, isNotEmpty);
    });

    test('generated test case has Dart code', () async {
      final result = await generator.generateFromCode(
        TestScenarios.fileHiveMainSnippet,
      );
      expect(result.testCases.first.dartCode, isNotEmpty);
    });

    test('generateFromDescription returns result', () async {
      final result = await generator.generateFromDescription(
        TestScenarios.fileTransferFeatureDescription,
      );
      expect(result, isA<TestGenerationResult>());
    });

    test('generateAccessibilityTests returns result', () async {
      final result = await generator.generateAccessibilityTests(
        'A file list widget showing transfer progress bars',
      );
      expect(result, isA<TestGenerationResult>());
    });

    test('toJson includes testCases and metadata', () async {
      final result =
          await generator.generateFromCode(TestScenarios.cleanDartCode);
      final json = result.toJson();
      expect(json.containsKey('testCases'), isTrue);
      expect(json.containsKey('totalGenerated'), isTrue);
    });

    test('handles malformed provider JSON gracefully', () async {
      final badProvider = MockAiProvider(responses: const ['{{bad json']);
      final badGenerator = TestGenerator(badProvider);
      final result =
          await badGenerator.generateFromCode(TestScenarios.cleanDartCode);
      expect(result.testCases, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // ReportGenerator
  // ---------------------------------------------------------------------------
  group('ReportGenerator', () {
    late ReportGenerator reportGenerator;
    late AiTestReport report;

    setUp(() async {
      reportGenerator = const ReportGenerator(appName: 'FileHive');

      final analysisResult = await TestAnalyzer(MockAnalysisProvider())
          .analyze(TestScenarios.mixedExecutions());
      final bugResult = await BugDetector(MockBugDetectionProvider())
          .analyzeCode(TestScenarios.fileHiveMainSnippet);
      final genResult = await TestGenerator(MockTestGenerationProvider())
          .generateFromCode(TestScenarios.fileHiveMainSnippet);

      report = AiTestReport(
        appName: 'FileHive',
        generatedAt: DateTime(2025, 1, 1),
        analysisResult: analysisResult,
        bugDetectionResult: bugResult,
        generationResult: genResult,
      );
    });

    test('AiTestReport toJson includes appName', () {
      final json = report.toJson();
      expect(json['appName'], equals('FileHive'));
    });

    test('AiTestReport toJson includes generatedAt', () {
      final json = report.toJson();
      expect(json['generatedAt'], isNotNull);
    });

    test('generateJson creates file with valid JSON', () async {
      const path = '/tmp/ai_test_report_test.json';
      await reportGenerator.generateJson(report, outputPath: path);
      final content = File(path).readAsStringSync();
      expect(content, contains('FileHive'));
    });

    test('generateHtml creates file with HTML content', () async {
      const path = '/tmp/ai_test_report_test.html';
      await reportGenerator.generateHtml(report, outputPath: path);
      final content = File(path).readAsStringSync();
      expect(content, contains('<!DOCTYPE html>'));
      expect(content, contains('FileHive'));
    });
  });

  // ---------------------------------------------------------------------------
  // AiProviderConfig
  // ---------------------------------------------------------------------------
  group('AiProviderConfig', () {
    test('uses provided values', () {
      const cfg = AiProviderConfig(
        apiKey: 'test-key',
        model: 'gpt-4',
        maxTokens: 1024,
        temperature: 0.5,
      );
      expect(cfg.apiKey, equals('test-key'));
      expect(cfg.model, equals('gpt-4'));
      expect(cfg.maxTokens, equals(1024));
      expect(cfg.temperature, equals(0.5));
    });

    test('defaults are sensible', () {
      const cfg = AiProviderConfig(apiKey: 'k', model: 'm');
      expect(cfg.maxTokens, greaterThan(0));
      expect(cfg.temperature, greaterThanOrEqualTo(0.0));
      expect(cfg.maxRetries, greaterThan(0));
    });
  });

  // ---------------------------------------------------------------------------
  // AiMessage
  // ---------------------------------------------------------------------------
  group('AiMessage', () {
    test('toJson produces correct keys', () {
      const msg = AiMessage(role: 'user', content: 'hello');
      final json = msg.toJson();
      expect(json['role'], equals('user'));
      expect(json['content'], equals('hello'));
    });
  });

  // ---------------------------------------------------------------------------
  // AiCompletionResult
  // ---------------------------------------------------------------------------
  group('AiCompletionResult', () {
    test('totalTokens sums prompt and completion tokens', () {
      const result = AiCompletionResult(
        content: 'hi',
        model: 'gpt-4',
        promptTokens: 40,
        completionTokens: 60,
        latency: Duration(milliseconds: 100),
      );
      expect(result.totalTokens, equals(100));
    });
  });
}
