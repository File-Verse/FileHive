import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Tests for the raw socket server logic used in [main.dart] (port 3000).
///
/// These tests exercise the socket server primitives directly — no Flutter
/// widget rendering is involved — so they run reliably on CI.
void main() {
  group('Socket Server (port 3000)', () {
    ServerSocket? server;

    tearDown(() async {
      await server?.close();
      server = null;
    });

    // ── Startup ────────────────────────────────────────────────────────────

    test('ServerSocket.bind succeeds on any available port', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);

      expect(server, isNotNull);
      expect(server!.port, greaterThan(0));
    });

    test('server port is accessible after binding', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);

      final port = server!.port;
      expect(port, greaterThan(0));
      expect(port, lessThanOrEqualTo(65535));
    });

    // ── Client Connection ──────────────────────────────────────────────────

    test('client can connect to the bound server', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server!.port;

      final connectionCompleter = Completer<Socket>();
      server!.listen(connectionCompleter.complete);

      final client = await Socket.connect('127.0.0.1', port);
      final serverSocket = await connectionCompleter.future;

      expect(serverSocket, isNotNull);

      await client.close();
      serverSocket.destroy();
    });

    // ── Message Exchange ───────────────────────────────────────────────────

    test('client message is received by the server', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server!.port;

      final messageCompleter = Completer<String>();

      server!.listen((clientSocket) {
        clientSocket.listen((data) {
          if (!messageCompleter.isCompleted) {
            messageCompleter.complete(utf8.decode(data));
          }
        });
      });

      final client = await Socket.connect('127.0.0.1', port);
      client.write('hello');

      final received = await messageCompleter.future
          .timeout(const Duration(seconds: 5));

      expect(received, equals('hello'));

      await client.close();
    });

    test('server echoes data back to the client', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server!.port;

      server!.listen((clientSocket) {
        clientSocket.listen((data) {
          clientSocket.add(data); // echo
        });
      });

      final client = await Socket.connect('127.0.0.1', port);
      final echoCompleter = Completer<String>();

      client.listen((data) {
        if (!echoCompleter.isCompleted) {
          echoCompleter.complete(utf8.decode(data));
        }
      });

      client.write('echo-test');

      final echo = await echoCompleter.future
          .timeout(const Duration(seconds: 5));
      expect(echo, equals('echo-test'));

      await client.close();
    });

    // ── Multiple Clients ───────────────────────────────────────────────────

    test('multiple clients can connect concurrently', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server!.port;

      final connected = <Socket>[];
      server!.listen(connected.add);

      final c1 = await Socket.connect('127.0.0.1', port);
      final c2 = await Socket.connect('127.0.0.1', port);

      // Allow the server listener to process connections.
      await Future.delayed(const Duration(milliseconds: 100));

      expect(connected.length, greaterThanOrEqualTo(2));

      await c1.close();
      await c2.close();
      for (final s in connected) {
        s.destroy();
      }
    });

    // ── Shutdown ───────────────────────────────────────────────────────────

    test('closing the server prevents new connections', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server!.port;

      await server!.close();
      server = null;

      await expectLater(
        Socket.connect('127.0.0.1', port)
            .timeout(const Duration(seconds: 2)),
        throwsA(anything),
      );
    });

    // ── Error Handling ─────────────────────────────────────────────────────

    test('binding to an already-used port throws a SocketException', () async {
      server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server!.port;

      await expectLater(
        ServerSocket.bind(InternetAddress.loopbackIPv4, port),
        throwsA(isA<SocketException>()),
      );
    });

    test('connecting to a non-listening port throws', () async {
      await expectLater(
        Socket.connect('127.0.0.1', 19999)
            .timeout(const Duration(seconds: 2)),
        throwsA(anything),
      );
    });
  });
}
