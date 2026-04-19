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

  group('GET /ping', () {
    test('200 OK aana chahiye', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(200));
    });

    test('Response mein app:FileHive hona chahiye', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();

      expect(body, contains('FileHive'));
    });

    test('Response mein device name hona chahiye', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();

      expect(body, contains('Test Device'));
    });
  });

  group('GET /device-info', () {
    test('200 OK aana chahiye', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(200));
    });

    test('Response mein IP hona chahiye', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/device-info'));
      final response = await serverRoutes.handler(request);
      final body = await response.readAsString();

      expect(body, contains('192.168.1.1'));
    });
  });

  group('Unknown Route', () {
    test('404 aana chahiye unknown route pe', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/unknown'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(404));
    });
  });

  group('OPTIONS /ping', () {
    test('CORS response 200 aana chahiye', () async {
      final request = Request('OPTIONS', Uri.parse('http://localhost:8080/ping'));
      final response = await serverRoutes.handler(request);

      expect(response.statusCode, equals(200));
    });
  });
}