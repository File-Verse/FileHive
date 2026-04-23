import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/form_data.dart';

import '../transfer/file_save_service.dart';

class ServerRoutes {
  final String deviceName;
  final String deviceIp;
  final int port;

  ServerRoutes({
    required this.deviceName,
    required this.deviceIp,
    required this.port,
  });

  // ─── MAIN HANDLER ─────────────────────────

  Handler get handler {
    return (Request request) async {
      final path = request.url.path;
      final method = request.method.toUpperCase();

      if (method == 'OPTIONS') return _corsResponse();
      if (method == 'GET' && path == 'ping') return _handlePing();
      if (method == 'GET' && path == 'device-info') {
        return _handleDeviceInfo();
      }
      if (method == 'POST' && path == 'upload') {
        return await _handleUpload(request);
      }

      return Response.notFound(
        jsonEncode({'error': 'Route not found', 'path': path}),
        headers: _jsonHeaders(),
      );
    };
  }

  // ─── PING ─────────────────────────

  Response _handlePing() {
    return Response.ok(
      jsonEncode({
        'status': 'ok',
        'name': deviceName,
        'ip': deviceIp,
        'port': port,
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: _jsonHeaders(),
    );
  }

  // ─── DEVICE INFO ─────────────────────────

  Response _handleDeviceInfo() {
    return Response.ok(
      jsonEncode({
        'name': deviceName,
        'ip': deviceIp,
        'port': port,
        'platform': Platform.operatingSystem,
      }),
      headers: _jsonHeaders(),
    );
  }

  // ─── UPLOAD (CORRECT STREAM VERSION) ─────────────────────────

  Future<Response> _handleUpload(Request request) async {
    try {
      Uint8List? fileBytes;
      String fileName = 'received_file.bin';

      // ✅ Stream handle karna (correct way)
      await for (final formData in request.multipartFormData) {
        if (formData.filename != null) {
          fileName = formData.filename!;
          fileBytes = await formData.part.readBytes();
          break;
        }
      }

      if (fileBytes == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'File nahi mila'}),
          headers: _jsonHeaders(),
        );
      }

      // ✅ Save file
      final savedPath = await FileSaveService.saveFile(
        fileName: fileName,
        bytes: fileBytes,
      );

      return Response.ok(
        jsonEncode({
          'saved': true,
          'fileName': fileName,
          'path': savedPath,
          'size': fileBytes.length,
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: _jsonHeaders(),
      );
    } on FileSaveException catch (e) {
      return Response(
        500,
        body: jsonEncode({'error': e.message}),
        headers: _jsonHeaders(),
      );
    } catch (e) {
      return Response(
        500,
        body: jsonEncode({'error': 'Upload failed: $e'}),
        headers: _jsonHeaders(),
      );
    }
  }

  // ─── HEADERS ─────────────────────────

  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };
  }

  Response _corsResponse() {
    return Response.ok('', headers: _jsonHeaders());
  }
}