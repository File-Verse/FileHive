import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
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

  Handler get handler {
    return (Request request) async {
      final path = request.url.path;
      final method = request.method.toUpperCase();

      if (method == 'OPTIONS') return _corsResponse();
      if (method == 'GET' && path == 'ping') return _handlePing();
      if (method == 'GET' && path == 'device-info') return _handleDeviceInfo();
      if (method == 'POST' && path == 'upload') return await _handleUpload(request);

      return Response.notFound(
        jsonEncode({'error': 'Route not found', 'path': path}),
        headers: _jsonHeaders(),
      );
    };
  }

  Response _handlePing() {
    return Response.ok(
      jsonEncode({
        'status': 'ok',
        'app': 'FileHive',
        'name': deviceName,
        'ip': deviceIp,
        'port': port,
        'mode': 'receiver',
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: _jsonHeaders(),
    );
  }

  Response _handleDeviceInfo() {
    return Response.ok(
      jsonEncode({
        'name': deviceName,
        'ip': deviceIp,
        'port': port,
        'platform': Platform.operatingSystem,
        'app': 'FileHive',
        'version': '1.0.0',
      }),
      headers: _jsonHeaders(),
    );
  }

  Future<Response> _handleUpload(Request request) async {
    try {
      final contentType = request.headers['content-type'] ?? '';
      if (!contentType.contains('multipart/form-data')) {
        return Response(400,
            body: jsonEncode({'error': 'Multipart request expected'}),
            headers: _jsonHeaders());
      }

      final boundary = RegExp(r'boundary=([^\s;]+)')
          .firstMatch(contentType)
          ?.group(1);
      if (boundary == null) {
        return Response(400,
            body: jsonEncode({'error': 'Boundary nahi mila'}),
            headers: _jsonHeaders());
      }

      String? fileName;
      Uint8List? fileBytes;

      final bodyBytes = await request.read().expand((x) => x).toList();
      final bodyString = String.fromCharCodes(bodyBytes);
      final parts = bodyString.split('--$boundary');

      for (final part in parts) {
        if (part.contains('filename=')) {
          final headerBody = part.split('\r\n\r\n');
          if (headerBody.length >= 2) {
            final header = headerBody[0];
            final fileNameMatch =
            RegExp(r'filename="([^"]*)"').firstMatch(header);
            fileName = fileNameMatch?.group(1) ?? 'received_file.bin';
            final content = headerBody.sublist(1).join('\r\n\r\n');
            final cleanContent = content.endsWith('\r\n')
                ? content.substring(0, content.length - 2)
                : content;
            fileBytes = Uint8List.fromList(cleanContent.codeUnits);
          }
        }
      }

      if (fileBytes == null || fileName == null) {
        return Response(400,
            body: jsonEncode({'error': 'File data nahi mila'}),
            headers: _jsonHeaders());
      }

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
      return Response(500,
          body: jsonEncode({'error': e.message}),
          headers: _jsonHeaders());
    } catch (e) {
      return Response(500,
          body: jsonEncode({'error': 'Upload failed: $e'}),
          headers: _jsonHeaders());
    }
  }

  Future<Uint8List> _collectBytes(dynamic part) async {
    final chunks = <int>[];
    await for (final chunk in part) {
      chunks.addAll(chunk);
    }
    return Uint8List.fromList(chunks);
  }

  String? _extractPartName(String contentDisposition) {
    final nameMatch =
    RegExp(r'name="([^"]*)"').firstMatch(contentDisposition);
    return nameMatch?.group(1);
  }

  String? _extractFileName(String contentDisposition) {
    final fileNameMatch =
    RegExp(r'filename="([^"]*)"').firstMatch(contentDisposition);
    return fileNameMatch?.group(1);
  }

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