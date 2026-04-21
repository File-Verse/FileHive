import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'package:filehive/services/network/network_info_service.dart';
import 'package:filehive/services/network/mdns_service.dart';

class SendService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  final NetworkInfoService _networkInfoService = NetworkInfoService();
  final MdnsService _mdnsService = MdnsService();

  static const int chunkSize = 1024 * 1024; // 1MB

  // ───────────────────────────────────────────────
  // 🔥 AUTO PICK + AUTO SEND
  // ───────────────────────────────────────────────
  Future<void> pickAndSendFile({
    required String token,
    required Function(double progress) onProgress,
    required Function(String error) onError,
  }) async {
    try {
      // 🔥 STEP 1: DISCOVER DEVICE
      final device = await _getReceiverDevice();

      if (device == null) {
        onError("❌ No receiver found");
        return;
      }

      print("📡 Found: ${device.ip}:${device.port}");

      // 🔥 STEP 2: PICK FILE
      final file = await pickFile();

      if (file == null) {
        onError("No file selected");
        return;
      }

      // 🔥 STEP 3: SEND
      await uploadToReceiver(
        file: file,
        receiverIP: device.ip,
        port: device.port,
        token: token,
        onProgress: onProgress,
        onError: onError,
      );
    } catch (e) {
      onError("❌ pickAndSend error: $e");
    }
  }

  // ───────────────────────────────────────────────
  // 📂 FILE PICK
  // ───────────────────────────────────────────────
  Future<File?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      return File(result.files.single.path!);
    } catch (e) {
      print('❌ pickFile error: $e');
      return null;
    }
  }

  // ───────────────────────────────────────────────
  // 🌐 DEVICE DISCOVERY (mDNS + fallback)
  // ───────────────────────────────────────────────
  Future<DiscoveredDevice?> _getReceiverDevice() async {
    await _mdnsService.start();

    try {
      final devices = await _mdnsService.scanDevices();

      if (devices.isNotEmpty) {
        return devices.first; // 🔥 best case
      }

      // ⚠️ FALLBACK (same WiFi IP guess)
      final myIP = await _networkInfoService.getWifiIP();

      if (myIP != null) {
        final base = myIP.substring(0, myIP.lastIndexOf('.'));
        final guessIP = "$base.1"; // router ya common device

        print("⚠️ Fallback IP try: $guessIP");

        return DiscoveredDevice(
          name: "Fallback",
          ip: guessIP,
          port: 8080,
        );
      }

      return null;
    } catch (e) {
      print("❌ Discovery error: $e");
      return null;
    } finally {
      await _mdnsService.stop();
    }
  }

  // ───────────────────────────────────────────────
  // 🔐 CHECKSUM
  // ───────────────────────────────────────────────
  String _getChecksum(List<int> bytes) {
    return md5.convert(bytes).toString();
  }

  // ───────────────────────────────────────────────
  // 🚀 SEND CHUNK
  // ───────────────────────────────────────────────
  Future<bool> _sendChunk({
    required String receiverIP,
    required int port,
    required String token,
    required String filename,
    required int chunkIndex,
    required int totalChunks,
    required int fileSize,
    required List<int> chunkData,
  }) async {
    try {
      final checksum = _getChecksum(chunkData);

      await _dio.post(
        'http://$receiverIP:$port/upload',
        data: chunkData,
        options: Options(
          headers: {
            'X-Filename': filename,
            'X-Chunk-Index': chunkIndex.toString(),
            'X-Total-Chunks': totalChunks.toString(),
            'X-File-Size': fileSize.toString(),
            'X-Checksum': checksum,
            'X-Token': token,
            'Content-Type': 'application/octet-stream',
          },
        ),
      );

      return true;
    } catch (e) {
      print("❌ Chunk $chunkIndex failed: $e");
      return false;
    }
  }

  // ───────────────────────────────────────────────
  // 📤 UPLOAD FILE
  // ───────────────────────────────────────────────
  Future<bool> uploadToReceiver({
    required File file,
    required String receiverIP,
    required int port,
    required String token,
    required Function(double progress) onProgress,
    required Function(String error) onError,
  }) async {
    RandomAccessFile? raf;

    try {
      final fileSize = await file.length();
      final filename = p.basename(file.path);
      final totalChunks = (fileSize / chunkSize).ceil();

      raf = await file.open(mode: FileMode.read);

      for (int i = 0; i < totalChunks; i++) {
        int remaining = fileSize - (i * chunkSize);
        int bytesToRead =
        remaining > chunkSize ? chunkSize : remaining;

        final chunkData = await raf.read(bytesToRead);

        bool success = false;

        for (int attempt = 0; attempt < 3; attempt++) {
          success = await _sendChunk(
            receiverIP: receiverIP,
            port: port,
            token: token,
            filename: filename,
            chunkIndex: i,
            totalChunks: totalChunks,
            fileSize: fileSize,
            chunkData: chunkData,
          );

          if (success) break;

          await Future.delayed(const Duration(seconds: 1));
        }

        if (!success) {
          await raf.close();
          onError("❌ Chunk $i failed");
          return false;
        }

        onProgress((i + 1) / totalChunks);
      }

      await raf.close();
      print("✅ File sent");

      return true;
    } catch (e) {
      onError("❌ Upload error: $e");
      await raf?.close();
      return false;
    }
  }
}