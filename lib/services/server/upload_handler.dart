import 'dart:io';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';

class UploadHandler {
  static Future<Response> handle(Request req) async {
    try {
      // File name header se lo
      final fileName = req.headers['x-file-name'] ?? 'received_file';

      // Body ke bytes directly read karo
      final bytesList = await req
          .read()
          .expand((chunk) => chunk)
          .toList();
      final fileBytes = Uint8List.fromList(bytesList);

      // Save karo Downloads/FileHive/ mein
      final dir = Directory('/storage/emulated/0/Download/FileHive');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      print('✅ File saved: ${file.path}');

      return Response.ok(
        '{"saved": true, "fileName": "$fileName"}',
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('❌ Upload error: $e');
      return Response.internalServerError(body: 'Upload failed: $e');
    }
  }
}