import 'package:filehive/services/ai_testing/test_analyzer.dart';

/// Predefined test scenarios used by the integration test suite.
///
/// Each scenario contains the input data and expected outcomes so tests
/// can be written concisely without repeating setup logic.
class TestScenarios {
  TestScenarios._();

  // ---------------------------------------------------------------------------
  // Sample Dart source code snippets for code analysis
  // ---------------------------------------------------------------------------

  /// FileHive main.dart snippet with intentional issues for bug-detection tests.
  static const String fileHiveMainSnippet = r'''
import 'dart:io';
import 'dart:convert';

class HomeScreen {
  ServerSocket? server;
  Socket? socket;

  void startServer() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 3000);
    server!.listen((client) {
      socket = client;
      client.listen((data) {
        String msg = utf8.decode(data);
        print('Client: $msg');
      });
    });
  }

  void sendMessage(String text) {
    // Bug: no null check on socket
    socket!.write(text);
  }

  void connectToServer() async {
    // Bug: hardcoded IP address
    socket = await Socket.connect('10.66.212.46', 3000)
        .timeout(Duration(seconds: 5));
  }
}
''';

  /// Clean Dart code with no obvious bugs.
  static const String cleanDartCode = r'''
import 'dart:io';

class NetworkService {
  Socket? _socket;

  Future<bool> connect(String host, int port) async {
    try {
      _socket = await Socket.connect(host, port)
          .timeout(const Duration(seconds: 10));
      return true;
    } catch (_) {
      return false;
    }
  }

  void send(String message) {
    _socket?.write(message);
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }
}
''';

  // ---------------------------------------------------------------------------
  // Sample test execution data
  // ---------------------------------------------------------------------------

  /// A mix of passing and failing test executions for analysis tests.
  static List<TestExecutionData> mixedExecutions() => [
        const TestExecutionData(
          testName: 'GET /ping returns 200',
          passed: true,
          duration: Duration(milliseconds: 45),
        ),
        const TestExecutionData(
          testName: 'GET /device-info contains IP',
          passed: true,
          duration: Duration(milliseconds: 52),
        ),
        const TestExecutionData(
          testName: 'sendMessage sends to socket',
          passed: false,
          duration: Duration(milliseconds: 10),
          errorMessage: 'Null check operator used on a null value',
          stackTrace: '#0 HomeScreen.sendMessage (lib/main.dart:22)',
        ),
        const TestExecutionData(
          testName: 'connectToServer connects successfully',
          passed: false,
          duration: Duration(milliseconds: 5001),
          errorMessage: 'SocketException: Connection refused',
          stackTrace: '#0 HomeScreen.connectToServer (lib/main.dart:28)',
        ),
      ];

  /// All-passing executions for happy-path analysis tests.
  static List<TestExecutionData> allPassingExecutions() => [
        const TestExecutionData(
          testName: 'server starts on port 3000',
          passed: true,
          duration: Duration(milliseconds: 30),
        ),
        const TestExecutionData(
          testName: 'client connects to server',
          passed: true,
          duration: Duration(milliseconds: 80),
        ),
        const TestExecutionData(
          testName: 'message is echoed back',
          passed: true,
          duration: Duration(milliseconds: 15),
        ),
      ];

  // ---------------------------------------------------------------------------
  // Sample feature descriptions for test generation
  // ---------------------------------------------------------------------------

  static const String fileTransferFeatureDescription = '''
FileHive is a Flutter mobile app that transfers files between devices over a
local Wi-Fi network without an internet connection.

Key features:
- Sender picks files using a file picker
- Sender starts a local HTTP server on port 8080
- Receiver discovers the sender via mDNS
- Files are transferred over HTTP with progress reporting
- Transfer success/failure screens are shown at the end
''';

  static const String networkDiscoveryFeatureDescription = '''
The mDNS discovery service in FileHive:
- Registers the device as "_filehive._tcp" on the local network
- Scans for other FileHive devices on the same network
- Returns a list of discovered devices with name and IP address
- Updates automatically when devices appear or disappear
''';

  // ---------------------------------------------------------------------------
  // Sample test output logs
  // ---------------------------------------------------------------------------

  static const String failingTestOutputLog = '''
00:01 +0: loading test/services/server/routes_test.dart
00:02 +3 -1: GET /ping Response mein app:FileHive hona chahiye [E]
  Expected: contains 'FileHive'
  Actual: '{"status":"ok","device":"Test Device","port":8080}'
  package:test_api/src/expect/expect.dart 147:31 fail
  test/services/server/routes_test.dart 29:7 main.<fn>.<fn>

00:03 +5 -1: Some tests failed.
''';

  static const String passingTestOutputLog = '''
00:00 +0: loading test/services/server/routes_test.dart
00:01 +1: GET /ping 200 OK aana chahiye
00:01 +2: GET /ping Response mein app:FileHive hona chahiye
00:01 +3: GET /ping Response mein device name hona chahiye
00:02 +4: GET /device-info 200 OK aana chahiye
00:02 +5: GET /device-info Response mein IP hona chahiye
00:03 +5: All tests passed!
''';
}
