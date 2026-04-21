import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileSaveService {
  static const String _folderName = 'FileHive';

  // ───────────────────────────────────────────────
  // 📁 GET SAVE DIRECTORY
  // ───────────────────────────────────────────────
  static Future<Directory> _getSaveDirectory() async {
    Directory baseDir;

    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();

      if (dir == null) {
        throw FileSaveException("Storage access failed");
      }

      baseDir = Directory('${dir.path}/$_folderName');
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      baseDir = Directory('${dir.path}/$_folderName');
    } else {
      final dir = await getDownloadsDirectory();
      baseDir = Directory('${dir!.path}/$_folderName');
    }

    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    return baseDir;
  }

  // ───────────────────────────────────────────────
  // 🔥 UNIQUE FILE PATH (NEW - IMPORTANT)
  // ───────────────────────────────────────────────
  static Future<String> getUniqueFilePath(String fileName) async {
    final dir = await _getSaveDirectory();

    final safeName = _sanitizeFileName(fileName);
    final uniqueName = await _resolveFileName(dir, safeName);

    return '${dir.path}/$uniqueName';
  }

  // ───────────────────────────────────────────────
  // 💾 SAVE FILE (SMALL FILES)
  // ───────────────────────────────────────────────
  static Future<String> saveFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final path = await getUniqueFilePath(fileName);

      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      return path;
    } catch (e) {
      throw FileSaveException('Save error: $e');
    }
  }

  // ───────────────────────────────────────────────
  // 🚀 STREAM SAVE (LARGE FILES)
  // ───────────────────────────────────────────────
  static Future<IOSink> openFileSink(String fileName) async {
    final path = await getUniqueFilePath(fileName);
    final file = File(path);

    return file.openWrite();
  }

  // ───────────────────────────────────────────────
  // 🧹 CLEAN FILE NAME
  // ───────────────────────────────────────────────
  static String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }

  // ───────────────────────────────────────────────
  // 🔁 DUPLICATE HANDLE
  // ───────────────────────────────────────────────
  static Future<String> _resolveFileName(
      Directory dir,
      String fileName,
      ) async {
    String name = fileName;
    int count = 1;

    while (await File('${dir.path}/$name').exists()) {
      final dot = fileName.lastIndexOf('.');

      String base =
      dot != -1 ? fileName.substring(0, dot) : fileName;
      String ext = dot != -1 ? fileName.substring(dot) : '';

      name = '${base}_$count$ext';
      count++;
    }

    return name;
  }

  // ───────────────────────────────────────────────
  // 📂 LIST FILES
  // ───────────────────────────────────────────────
  static Future<List<File>> getSavedFiles() async {
    try {
      final dir = await _getSaveDirectory();
      if (!await dir.exists()) return [];

      final files = dir.listSync().whereType<File>().toList();

      files.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));

      return files;
    } catch (_) {
      return [];
    }
  }

  // ───────────────────────────────────────────────
  // ❌ DELETE FILE
  // ───────────────────────────────────────────────
  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // 📊 STORAGE CHECK
  // ───────────────────────────────────────────────
  static Future<int> getFreeSpace() async {
    try {
      final dir = await _getSaveDirectory();
      final stat = await dir.stat();

      return stat.size; // approx only
    } catch (_) {
      return 0;
    }
  }
}

// ───────────────────────────────────────────────
// ❗ CUSTOM EXCEPTION
// ───────────────────────────────────────────────
class FileSaveException implements Exception {
  final String message;
  FileSaveException(this.message);

  @override
  String toString() => 'FileSaveException: $message';
}