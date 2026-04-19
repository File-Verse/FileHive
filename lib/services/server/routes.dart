import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_multipart/shelf_multipart.dart';
import '../transfer/file_save_service.dart';

class ServerRoutes {
  /// Device ka naam — customize kar sakte ho
  final String deviceName;
  final String deviceIp;
  final int port;

  ServerRoutes({
    required this.deviceName,
    required this.deviceIp,
    required this.port,
  });

  /// Main handler — sabhi routes yahan se handle honge
  Handler get handler {
    return (Request request) async {
      final path = request.url.path;
      final method = request.method.toUpperCase();

      // CORS headers — cross-device requests allow karo
      if (method == 'OPTIONS') {
        return _corsResponse();
      }

      // Route matching
      if (method == 'GET' && path == 'ping') {
        return _handlePing();
      }

      if (method == 'GET' && path == 'device-info') {
        return _handleDeviceInfo();
      }

      if (method == 'POST' && path == 'upload') {
        return await _handleUpload(request);
      }

      // Route nahi mila
      return Response.notFound(
        jsonEncode({'error': 'Route not found', 'path': path}),
        headers: _jsonHeaders(),
      );
    };
  }

  // ─────────────────────────────────────────
  // GET /ping
  // Sender check karta hai — receiver online hai?
  // ─────────────────────────────────────────
  Response _handlePing() {
    final responseBody = jsonEncode({
      'status': 'ok',
      'app': 'FileHive',
      'name': deviceName,
      'ip': deviceIp,
      'port': port,
      'mode': 'receiver',
      'timestamp': DateTime.now().toIso8601String(),
    });

    return Response.ok(responseBody, headers: _jsonHeaders());
  }

  // ─────────────────────────────────────────
  // GET /device-info
  // Detailed device information return karta hai
  // ─────────────────────────────────────────
  Response _handleDeviceInfo() {
    final responseBody = jsonEncode({
      'name': deviceName,
      'ip': deviceIp,
      'port': port,
      'platform': Platform.operatingSystem,
      'app': 'FileHive',
      'version': '1.0.0',
    });

    return Response.ok(responseBody, headers: _jsonHeaders());
  }

  // ─────────────────────────────────────────
  // POST /upload
  // Sender se file receive karta hai — multipart form data
  // ─────────────────────────────────────────
  Future<Response> _handleUpload(Request request) async {
    try {
      // Multipart request hai ya nahi check karo
      if (!request.isMultipart) {
        return Response(
          400,
          body: jsonEncode({
            'error': 'Multipart request expected',
            'received': request.mimeType,
          }),
          headers: _jsonHeaders(),
        );
      }

      String? fileName;
      Uint8List? fileBytes;

      // Multipart parts ko parse karo
      await for (final part in request.parts) {
        final contentDisposition = part.headers['content-disposition'] ?? '';
        final partName = _extractPartName(contentDisposition);
        final bytes = await _collectBytes(part);

        if (partName == 'file') {
          fileBytes = bytes;
          // File name extract karo content-disposition se
          fileName = _extractFileName(contentDisposition);

          // Agar content-disposition mein naam nahi — MIME se guess karo
          if (fileName == null || fileName.isEmpty) {
            final mimeType = part.headers['content-type'] ?? 'application/octet-stream';
            final ext = extensionFromMime(mimeType) ?? 'bin';
            fileName = 'received_file_${DateTime.now().millisecondsSinceEpoch}.$ext';
          }
        }
      }

      // File data mila nahi
      if (fileBytes == null || fileName == null) {
        return Response(
          400,
          body: jsonEncode({'error': 'File data nahi mila request mein'}),
          headers: _jsonHeaders(),
        );
      }

      // FileSaveService se file save karo
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

  // ─────────────────────────────────────────
  // Helper Functions
  // ─────────────────────────────────────────

  /// Multipart part ke bytes collect karo
  Future<Uint8List> _collectBytes(dynamic part) async {
    final chunks = <int>[];
    await for (final chunk in part) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  /// Content-Disposition header se part name nikalo
  /// e.g. 'form-data; name="file"' => 'file'
  String? _extractPartName(String contentDisposition) {
    final nameMatch = RegExp(r'name="([^"]*)"').firstMatch(contentDisposition);
    return nameMatch?.group(1);
  }

  /// Content-Disposition se file name nikalo
  /// e.g. 'form-data; name="file"; filename="photo.jpg"' => 'photo.jpg'
  String? _extractFileName(String contentDisposition) {
    final fileNameMatch = RegExp(r'filename="([^"]*)"').firstMatch(contentDisposition);
    return fileNameMatch?.group(1);
  }

  /// Standard JSON response headers
  Map<String, String> _jsonHeaders() {
    return {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };
  }

  /// OPTIONS request ke liye CORS preflight response
  Response _corsResponse() {
    return Response.ok('', headers: _jsonHeaders());
  }
}