import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;

import 'package:filehive/services/network/network_info_service.dart';

class SendService {
  final Dio _dio = Dio();
  final NetworkInfoService _networkInfoService = NetworkInfoService();

  static const int CHUNK_SIZE = 1024 * 1024; // 1MB

  // ─────────────────────────────────────────────────
  // 🔥 1. PICK + SEND (NEW INTEGRATED METHOD)
  // ─────────────────────────────────────────────────
  Future<void> pickAndSendFile({
    required String receiverIP,
    required String token,
    required Function(double progress) onProgress,
    required Function(String error) onError,
  }) async {
    File? file = await pickFile();

    if (file == null) {
      onError("No file selected");
      return;
    }

    await uploadToReceiver(
      file: file,
      receiverIP: receiverIP,
      token: token,
      onProgress: onProgress,
      onError: onError,
    );
  }

  // ─────────────────────────────────────────────────
  // 2. FILE PICK KARO
  // ─────────────────────────────────────────────────
  Future<File?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result == null) return null;

      String? path = result.files.single.path;
      if (path == null) return null;

      return File(path);
    } catch (e) {
      print('pickFile error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────
  // 3. MULTIPLE FILES PICK KARO
  // ─────────────────────────────────────────────────
  Future<List<File>> pickMultipleFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result == null) return [];

      return result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();
    } catch (e) {
      print('pickMultipleFiles error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────────
  // 4. SENDER IP
  // ─────────────────────────────────────────────────
  Future<String?> getSenderIP() async {
    return await _networkInfoService.getWifiIP();
  }

  // ─────────────────────────────────────────────────
  // 5. CHECKSUM
  // ─────────────────────────────────────────────────
  String _getChecksum(List<int> bytes) {
    return md5.convert(bytes).toString();
  }

  // ─────────────────────────────────────────────────
  // 6. SINGLE CHUNK SEND
  // ─────────────────────────────────────────────────
  Future<bool> _sendChunk({
    required String receiverIP,
    required String token,
    required String filename,
    required int chunkIndex,
    required int totalChunks,
    required int fileSize,
    required List<int> chunkData,
  }) async {
    try {
      String checksum = _getChecksum(chunkData);

      await _dio.post(
        'http://$receiverIP:8080/upload',
        data: Stream.fromIterable([chunkData]),
        options: Options(
          headers: {
            'X-Filename': filename,
            'X-Chunk-Index': chunkIndex.toString(),
            'X-Total-Chunks': totalChunks.toString(),
            'X-File-Size': fileSize.toString(),
            'X-Checksum': checksum,
            'X-Token': token,
            'Content-Type': 'application/octet-stream',
            'Content-Length': chunkData.length.toString(),
          },
        ),
      );

      return true;
    } catch (e) {
      print('_sendChunk error (chunk $chunkIndex): $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // 7. MAIN UPLOAD METHOD
  // ─────────────────────────────────────────────────
  Future<bool> uploadToReceiver({
    required File file,
    required String receiverIP,
    required String token,
    required Function(double progress) onProgress,
    required Function(String error) onError,
  }) async {
    try {
      int fileSize = await file.length();
      String filename = p.basename(file.path);
      int totalChunks = (fileSize / CHUNK_SIZE).ceil();

      RandomAccessFile raf = await file.open(mode: FileMode.read);

      for (int i = 0; i < totalChunks; i++) {
        int start = i * CHUNK_SIZE;
        int bytesToRead = (start + CHUNK_SIZE > fileSize)
            ? fileSize - start
            : CHUNK_SIZE;

        List<int> chunkData = await raf.read(bytesToRead);

        bool sent = false;

        for (int attempt = 0; attempt < 3; attempt++) {
          sent = await _sendChunk(
            receiverIP: receiverIP,
            token: token,
            filename: filename,
            chunkIndex: i,
            totalChunks: totalChunks,
            fileSize: fileSize,
            chunkData: chunkData,
          );

          if (sent) break;
          await Future.delayed(const Duration(seconds: 1));
        }

        if (!sent) {
          await raf.close();
          onError('Chunk $i send nahi hua');
          return false;
        }

        double progress = (i + 1) / totalChunks;
        onProgress(progress);
      }

      await raf.close();
      return true;
    } catch (e) {
      onError('uploadToReceiver error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────
  // 8. MULTIPLE FILE UPLOAD
  // ─────────────────────────────────────────────────
  Future<void> uploadMultipleFiles({
    required List<File> files,
    required String receiverIP,
    required String token,
    required Function(int fileIndex, double progress) onProgress,
    required Function(int fileIndex) onFileComplete,
    required Function(String error) onError,
  }) async {
    for (int i = 0; i < files.length; i++) {
      bool success = await uploadToReceiver(
        file: files[i],
        receiverIP: receiverIP,
        token: token,
        onProgress: (progress) => onProgress(i, progress),
        onError: onError,
      );

      if (success) onFileComplete(i);
    }
  }
}