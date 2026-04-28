import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'file_save_service.dart';

class ReceiveService {
  HttpServer? _server;

  final Map<String, _ReceiveSession> _sessions = {};

  // ───────────────────────────────────────────────
  // 🚀 START SERVER
  // ───────────────────────────────────────────────
  Future<void> startServer(int port) async {
    try {
      if (_server != null) {
        print("⚠️ Server already running");
        return;
      }

      final router = Router();

      router.post('/upload', _handleUpload);

      final handler = Pipeline()
          .addMiddleware(logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(
        handler,
        InternetAddress.anyIPv4,
        port,
      );

      print("📡 Receiver server started on port $port");
    } catch (e) {
      print("❌ Server error: $e");
      rethrow;
    }
  }

  // ───────────────────────────────────────────────
  // 🔥 HANDLE UPLOAD CHUNK
  // ───────────────────────────────────────────────
  Future<Response> _handleUpload(Request request) async {
    try {
      final headers = request.headers;

      final filename = headers['x-filename'];
      final chunkIndex = int.tryParse(headers['x-chunk-index'] ?? '');
      final totalChunks = int.tryParse(headers['x-total-chunks'] ?? '');
      final fileSize = int.tryParse(headers['x-file-size'] ?? '');
      final checksum = headers['x-checksum'];
      final token = headers['x-token'];

      if (filename == null ||
          chunkIndex == null ||
          totalChunks == null ||
          fileSize == null ||
          checksum == null ||
          token == null) {
        return Response.badRequest(
          body: "❌ Missing upload headers",
        );
      }

      final chunkData = await _readRequestBytes(request);

      if (!_isChecksumValid(chunkData, checksum)) {
        return Response(
          400,
          body: "❌ Invalid checksum",
        );
      }

      final sessionKey = "$token-$filename";

      _ReceiveSession session;

      if (!_sessions.containsKey(sessionKey)) {
        final path = await FileSaveService.getUniqueFilePath(filename);

        session = _ReceiveSession(
          filePath: path,
          filename: filename,
          fileSize: fileSize,
          totalChunks: totalChunks,
        );

        _sessions[sessionKey] = session;

        print("📥 Receiving: $filename ($fileSize bytes)");
      } else {
        session = _sessions[sessionKey]!;
      }

      if (chunkIndex < session.nextChunkIndex) {
        print("⚠️ Duplicate chunk ignored: $chunkIndex");

        return Response.ok(
          "⚠️ Duplicate chunk ignored",
        );
      }

      if (chunkIndex != session.nextChunkIndex) {
        return Response(
          409,
          body:
          "❌ Invalid chunk order. Expected ${session.nextChunkIndex}, got $chunkIndex",
        );
      }

      final file = File(session.filePath);

      final sink = file.openWrite(
        mode: chunkIndex == 0 ? FileMode.write : FileMode.append,
      );

      sink.add(chunkData);
      await sink.flush();
      await sink.close();

      session.receivedBytes += chunkData.length;
      session.nextChunkIndex++;

      print(
        "📊 Progress: ${session.receivedBytes} / ${session.fileSize}",
      );

      if (session.nextChunkIndex >= session.totalChunks) {
        _sessions.remove(sessionKey);

        print("✅ File saved: ${session.filePath}");

        return Response.ok(
          "✅ File uploaded successfully",
        );
      }

      return Response.ok(
        "✅ Chunk $chunkIndex received",
      );
    } catch (e) {
      print("❌ Upload error: $e");

      return Response.internalServerError(
        body: "❌ Upload error: $e",
      );
    }
  }

  // ───────────────────────────────────────────────
  // 📦 READ REQUEST BYTES
  // ───────────────────────────────────────────────
  Future<List<int>> _readRequestBytes(Request request) async {
    final List<int> bytes = [];

    await for (final chunk in request.read()) {
      bytes.addAll(chunk);
    }

    return bytes;
  }

  // ───────────────────────────────────────────────
  // 🔐 CHECKSUM VALIDATION
  // ───────────────────────────────────────────────
  bool _isChecksumValid(List<int> bytes, String checksum) {
    final localChecksum = md5.convert(bytes).toString();
    return localChecksum == checksum;
  }

  // ───────────────────────────────────────────────
  // 🛑 STOP SERVER
  // ───────────────────────────────────────────────
  Future<void> stopServer() async {
    await _server?.close(force: true);
    _server = null;
    _sessions.clear();

    print("🛑 Server stopped");
  }
}

// ───────────────────────────────────────────────
// 📁 RECEIVE SESSION MODEL
// ───────────────────────────────────────────────
class _ReceiveSession {
  final String filePath;
  final String filename;
  final int fileSize;
  final int totalChunks;

  int receivedBytes = 0;
  int nextChunkIndex = 0;

  _ReceiveSession({
    required this.filePath,
    required this.filename,
    required this.fileSize,
    required this.totalChunks,
  });
}