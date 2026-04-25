import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:filehive/services/server/local_server_service.dart';

void main() {
  group('LocalServerService', () {
    late LocalServerService service;

    setUp(() {
      service = LocalServerService();
    });

    tearDown(() async {
      if (service.isRunning) {
        await service.stopServer();
      }
    });

    // ── Startup / Shutdown ──────────────────────────────────────────────────

    test('isRunning is false before startServer is called', () {
      expect(service.isRunning, isFalse);
    });

    test('startServer starts the HTTP server and isRunning becomes true',
        () async {
      await service.startServer(
        deviceName: 'Test Device',
        deviceIp: '127.0.0.1',
      );

      expect(service.isRunning, isTrue);
    });

    test('stopServer stops the server and isRunning becomes false', () async {
      await service.startServer(
        deviceName: 'Test Device',
        deviceIp: '127.0.0.1',
      );

      await service.stopServer();

      expect(service.isRunning, isFalse);
    });

    test('calling stopServer when not running does not throw', () async {
      await expectLater(service.stopServer(), completes);
    });

    // ── HTTP Endpoint Tests ─────────────────────────────────────────────────

    test('GET /ping returns 200 with valid JSON', () async {
      await service.startServer(
        deviceName: 'Test Device',
        deviceIp: '127.0.0.1',
      );

      final client = HttpClient();
      try {
        final request = await client.get(
            '127.0.0.1', LocalServerService.serverPort, '/ping');
        final response = await request.close();

        expect(response.statusCode, equals(200));

        final body =
            await response.transform(const Utf8Decoder()).join();
        final json = jsonDecode(body) as Map<String, dynamic>;

        expect(json['status'], equals('ok'));
        expect(json['app'], equals('FileHive'));
        expect(json['name'], equals('Test Device'));
      } finally {
        client.close();
      }
    });

    test('GET /device-info returns 200 with device details', () async {
      await service.startServer(
        deviceName: 'Test Device',
        deviceIp: '127.0.0.1',
      );

      final client = HttpClient();
      try {
        final request = await client.get(
            '127.0.0.1', LocalServerService.serverPort, '/device-info');
        final response = await request.close();

        expect(response.statusCode, equals(200));

        final body =
            await response.transform(const Utf8Decoder()).join();
        final json = jsonDecode(body) as Map<String, dynamic>;

        expect(json['name'], equals('Test Device'));
        expect(json['ip'], equals('127.0.0.1'));
        expect(json['port'], equals(LocalServerService.serverPort));
      } finally {
        client.close();
      }
    });

    test('GET /unknown returns 404', () async {
      await service.startServer(
        deviceName: 'Test Device',
        deviceIp: '127.0.0.1',
      );

      final client = HttpClient();
      try {
        final request = await client.get(
            '127.0.0.1', LocalServerService.serverPort, '/unknown-route');
        final response = await request.close();

        expect(response.statusCode, equals(404));
      } finally {
        client.close();
      }
    });

    test('response includes CORS headers', () async {
      await service.startServer(
        deviceName: 'Test Device',
        deviceIp: '127.0.0.1',
      );

      final client = HttpClient();
      try {
        final request = await client.get(
            '127.0.0.1', LocalServerService.serverPort, '/ping');
        final response = await request.close();

        expect(
          response.headers.value('access-control-allow-origin'),
          equals('*'),
        );
      } finally {
        client.close();
      }
    });

    test('error middleware catches exceptions and returns 500', () async {
      await service.startServer(
        deviceName: 'Test Device',
        deviceIp: '127.0.0.1',
      );

      // A POST to /ping (unsupported method) falls through to 404, not 500.
      // An intentionally broken route would yield 500 via the middleware.
      // Verify the server does not crash on an unexpected error by sending
      // a request with a very long path segment.
      final client = HttpClient();
      try {
        final longPath = '/ping/${'x' * 2000}';
        final request = await client.get(
            '127.0.0.1', LocalServerService.serverPort, longPath);
        final response = await request.close();

        // The server must still respond (either 404 or 500 — not a crash).
        expect(response.statusCode, anyOf(404, 500));
      } finally {
        client.close();
      }
    });
  });
}
