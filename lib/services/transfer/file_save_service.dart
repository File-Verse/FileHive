import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileSaveService {
  // FileHive folder name
  static const String _folderName = 'FileHive';

  /// Returns the save directory path
  /// Android: /storage/emulated/0/Download/FileHive/
  /// iOS/Desktop: App Documents/FileHive/
  static Future<Directory> _getSaveDirectory() async {
    Directory baseDir;

    if (Platform.isAndroid) {
      // Android pe Downloads folder use karo
      baseDir = Directory('/storage/emulated/0/Download/$_folderName');
    } else if (Platform.isIOS) {
      final docDir = await getApplicationDocumentsDirectory();
      baseDir = Directory('${docDir.path}/$_folderName');
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final docDir = await getDownloadsDirectory();
      baseDir = Directory('${docDir!.path}/$_folderName');
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      baseDir = Directory('${docDir.path}/$_folderName');
    }

    // Folder exist nahi karta toh create karo
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    return baseDir;
  }

  /// Main function — file bytes ko disk pe save karta hai
  /// Returns: saved file ka full path
  static Future<String> saveFile({
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final saveDir = await _getSaveDirectory();

      // Duplicate file name conflict handle karo
      final uniqueFileName = await _resolveFileName(saveDir, fileName);
      final filePath = '${saveDir.path}/$uniqueFileName';

      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw FileSaveException('File save karne mein error aaya: $e');
    }
  }

  /// Agar same naam ki file already exist karti hai
  /// toh timestamp suffix add karo — e.g. photo_1714000000.jpg
  static Future<String> _resolveFileName(
      Directory dir,
      String fileName,
      ) async {
    final file = File('${dir.path}/$fileName');

    if (!await file.exists()) {
      return fileName; // No conflict — same name use karo
    }

    // Name aur extension alag karo
    final dotIndex = fileName.lastIndexOf('.');
    final String name;
    final String ext;

    if (dotIndex != -1) {
      name = fileName.substring(0, dotIndex);
      ext = fileName.substring(dotIndex); // e.g. ".jpg"
    } else {
      name = fileName;
      ext = '';
    }

    // Timestamp suffix add karo
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${name}_$timestamp$ext';
  }

  /// Saved files ki list return karta hai
  static Future<List<FileSystemEntity>> getSavedFiles() async {
    try {
      final saveDir = await _getSaveDirectory();
      if (!await saveDir.exists()) return [];

      return saveDir.listSync().toList()
        ..sort((a, b) {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(aStat.modified); // Latest first
        });
    } catch (e) {
      return [];
    }
  }

  /// Ek specific file delete karo
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Available storage check karo (bytes mein)
  static Future<int> getAvailableStorage() async {
    try {
      final saveDir = await _getSaveDirectory();
      final stat = await saveDir.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }
}

/// Custom Exception class
class FileSaveException implements Exception {
  final String message;
  FileSaveException(this.message);

  @override
  String toString() => 'FileSaveException: $message';
}