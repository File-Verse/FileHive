import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';
import 'package:filehive/services/server/routes.dart';

void main() {
  late ServerRoutes serverRoutes;

  setUp(() {
    serverRoutes = ServerRoutes(
      deviceName: 'Test Device',
      deviceIp: '192.168.1.1',
      port: 8080,
    );
  });

  // ── GET /ping ──────────────────────────────────────────────────────────────

  group('GET /ping', () {
    test('returns 200 OK', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(200));
    });

    test('response body contains app:FileHive', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();

      expect(body, contains('FileHive'));
    });

    test('response body contains device name', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();

      expect(body, contains('Test Device'));
    });

    test('response body contains status ok', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['status'], equals('ok'));
    });

    test('response body contains ip and port', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['ip'], equals('192.168.1.1'));
      expect(json['port'], equals(8080));
    });

    test('response body contains timestamp', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['timestamp'], isNotNull);
      expect(json['timestamp'], isA<String>());
    });

    test('Content-Type header is application/json', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);

      expect(
        response.headers['content-type'],
        contains('application/json'),
      );
    });

    test('CORS header Access-Control-Allow-Origin is *', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);

      expect(
        response.headers['access-control-allow-origin'],
        equals('*'),
      );
    });
  });

  // ── GET /device-info ───────────────────────────────────────────────────────

  group('GET /device-info', () {
    test('returns 200 OK', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(200));
    });

    test('response body contains IP address', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();

      expect(body, contains('192.168.1.1'));
    });

    test('response body contains device name', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['name'], equals('Test Device'));
    });

    test('response body contains port', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['port'], equals(8080));
    });

    test('response body contains platform field', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['platform'], isNotNull);
      expect(json['platform'], isA<String>());
    });

    test('Content-Type header is application/json', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);

      expect(
        response.headers['content-type'],
        contains('application/json'),
      );
    });
  });

  // ── Unknown Route ──────────────────────────────────────────────────────────

  group('Unknown Route', () {
    test('returns 404 for unknown GET route', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/unknown'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(404));
    });

    test('404 body contains error message', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/unknown'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;

      expect(json['error'], isNotNull);
    });

    test('404 body contains the unknown path', () async {
      final request =
          Request('GET', Uri.parse('http://localhost:8080/no-such-route'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();

      expect(body, contains('no-such-route'));
    });
  });

  // ── OPTIONS (CORS pre-flight) ──────────────────────────────────────────────

  group('OPTIONS /ping', () {
    test('returns 200 for CORS pre-flight request', () async {
      final request =
          Request('OPTIONS', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(200));
    });

    test('CORS headers are present in OPTIONS response', () async {
      final request =
          Request('OPTIONS', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);

      expect(
        response.headers['access-control-allow-origin'],
        equals('*'),
      );
      expect(
        response.headers['access-control-allow-methods'],
        isNotNull,
      );
    });
  });

  // ── POST /upload (no body) ────────────────────────────────────────────────

  group('POST /upload', () {
    test('returns 400 when no multipart data is provided', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/upload'),
        headers: {'content-type': 'multipart/form-data; boundary=boundary'},
        body: '--boundary--\r\n', // empty multipart body
      );
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(400));
    });
  });
}
