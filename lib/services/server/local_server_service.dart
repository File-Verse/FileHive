import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'server_routes.dart'; // ✅ UploadHandler hata diya, ServerRoutes add kiya

class LocalServerService {
  HttpServer? _server;
  static const int serverPort = 8080;

  // ─── Server Start ─────────────────────────────────────────────────────────

  Future<void> startServer({
    required String deviceName,
    required String deviceIp,
  }) async {

    // ✅ ServerRoutes ko device info pass karo
    final routes = ServerRoutes(
      deviceName: deviceName,
      deviceIp: deviceIp,
      port: serverPort,
    );

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_errorMiddleware()) // ✅ Global error catching
        .addHandler(routes.handler);

    _server = await shelf_io.serve(handler, '0.0.0.0', serverPort);
    print('✅ Server started → http://$deviceIp:$serverPort');
  }

  // ─── Server Stop ──────────────────────────────────────────────────────────

  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    print('🛑 Server stopped');
  }

  // ─── Status ───────────────────────────────────────────────────────────────

  bool get isRunning => _server != null;

  // ─── Global Error Middleware ──────────────────────────────────────────────

  Middleware _errorMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        try {
          return await innerHandler(request);
        } catch (e, stack) {
          print('❌ Unhandled error: $e');
          print(stack);
          return Response.internalServerError(
            body: '{"error": "Internal server error"}',
            headers: {'Content-Type': 'application/json'},
          );
        }
      };
    };
  }
}