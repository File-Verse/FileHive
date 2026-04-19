import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'upload_handler.dart';

class LocalServerService {
  HttpServer? _server;
  static const int serverPort = 8080;

  // Server start karo
  Future<void> startServer() async {
    final router = Router();

    // GET /ping — sender check karega receiver online hai ya nahi
    router.get('/ping', (Request req) {
      return Response.ok(
        '{"status": "ok", "app": "FileHive"}',
        headers: {'Content-Type': 'application/json'},
      );
    });

    // POST /upload — yahan file aayegi sender se
    router.post('/upload', (Request req) async {
      return await UploadHandler.handle(req);
    });

    // GET /device-info — device ki basic info
    router.get('/device-info', (Request req) {
      return Response.ok(
        '{"name": "FileHive Device", "port": $serverPort, "app": "FileHive"}',
        headers: {'Content-Type': 'application/json'},
      );
    });

    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    _server = await shelf_io.serve(handler, '0.0.0.0', serverPort);
    print('✅ Server started on port $serverPort');
  }

  // Server stop karo
  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    print('🛑 Server stopped');
  }

  // Server chal raha hai ya nahi — check karne ke liye
  bool get isRunning => _server != null;
}