import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:filehive/services/network/mdns_service.dart';
import 'package:filehive/services/network/network_info_service.dart';

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

  Future<void> pickAndSendFile({
    required String token,
    String? manualIP,
    int manualPort = 8080,
    required Function(double progress) onProgress,
    required Function(String error) onError,
  }) async {
    try {
      final device = await _getReceiverDevice(
        manualIP: manualIP,
        manualPort: manualPort,
      );

      if (device == null) {
        onError('❌ No receiver found');
        return;
      }

      debugPrint('📡 Found receiver: ${device.ip}:${device.port}');

      final file = await pickFile();

      if (file == null) {
        onError('No file selected');
        return;
      }

      await uploadToReceiver(
        file: file,
        receiverIP: device.ip,
        port: device.port,
        token: token,
        onProgress: onProgress,
        onError: onError,
      );
    } catch (e) {
      onError('❌ pickAndSend error: $e');
    }
  }

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
      debugPrint('❌ pickFile error: $e');
      return null;
    }
  }

  Future<DiscoveredDevice?> _getReceiverDevice({
    String? manualIP,
    int manualPort = 8080,
  }) async {
    try {
      final devices = await _mdnsService.scanDevices();

      if (devices.isNotEmpty) {
        return devices.first;
      }

      if (manualIP != null && manualIP.trim().isNotEmpty) {
        final ip = manualIP.trim();

        if (!_isValidIP(ip)) {
          debugPrint('❌ Invalid manual IP: $ip');
          return null;
        }

        debugPrint('📌 Manual IP used: $ip:$manualPort');

        return DiscoveredDevice(
          name: 'Manual',
          ip: ip,
          port: manualPort,
        );
      }

      final fallbackIP = await _networkInfoService.getGatewayIpAddress() ??
          await _networkInfoService.guessGatewayIpAddress();

      if (fallbackIP != null && fallbackIP.isNotEmpty) {
        debugPrint('⚠️ Fallback IP try: $fallbackIP');

        return DiscoveredDevice(
          name: 'Fallback',
          ip: fallbackIP,
          port: 8080,
        );
      }

      return null;
    } catch (e) {
      debugPrint('❌ Discovery error: $e');
      return null;
    } finally {
      _mdnsService.stop();
    }
  }

  bool _isValidIP(String ip) {
    final regex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])\.){3}'
      r'(25[0-5]|2[0-4][0-9]|1?[0-9]?[0-9])$',
    );

    return regex.hasMatch(ip);
  }

  String _getChecksum(List<int> bytes) {
    return md5.convert(bytes).toString();
  }

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
      debugPrint('❌ Chunk $chunkIndex failed: $e');
      return false;
    }
  }

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
        final remaining = fileSize - (i * chunkSize);
        final bytesToRead = remaining > chunkSize ? chunkSize : remaining;

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
          onError('❌ Chunk $i failed after 3 attempts');
          return false;
        }

        onProgress((i + 1) / totalChunks);
      }

      debugPrint('✅ File sent successfully');
      return true;
    } catch (e) {
      onError('❌ Upload error: $e');
      return false;
    } finally {
      await raf?.close();
    }
  }
}