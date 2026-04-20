import 'dart:io';
import 'dart:convert';
import 'file_save_service.dart';

class ReceiveService {
  ServerSocket? _server;
  final FileSaveService _fileSaveService = FileSaveService();

  /// Start server
  Future<void> startServer(int port) async {
    try {
      _server = await ServerSocket.bind(
        InternetAddress.anyIPv4,
        port,
      );

      print("📡 Server started on port $port");

      _server!.listen((client) {
        print("🔌 Client connected: ${client.remoteAddress}");
        _handleClient(client);
      });
    } catch (e) {
      print("❌ Server error: $e");
      rethrow;
    }
  }

  /// Handle client
  void _handleClient(Socket client) async {
    List<int> buffer = [];

    IOSink? fileSink;
    File? file;

    String? fileName;
    int? fileSize;
    int receivedBytes = 0;
    bool metaReceived = false;

    try {
      await for (var data in client) {
        buffer.addAll(data);

        /// STEP 1: Read metadata
        if (!metaReceived && buffer.contains(10)) {
          int index = buffer.indexOf(10);

          String metaString =
          utf8.decode(buffer.sublist(0, index));
          Map meta = jsonDecode(metaString);

          fileName = meta["fileName"];
          fileSize = meta["fileSize"];

          /// ✅ NULL CHECK (important fix)
          if (fileName == null || fileSize == null) {
            throw Exception("Invalid metadata");
          }

          print("📥 Receiving: $fileName ($fileSize bytes)");

          /// 🔥 FileSaveService use
          String path =
          await _fileSaveService.getUniqueFilePath(fileName);

          file = File(path);
          fileSink = file.openWrite();

          /// Remove metadata from buffer
          buffer = buffer.sublist(index + 1);
          metaReceived = true;
        }

        /// STEP 2: Write file chunks
        if (metaReceived && fileSink != null) {
          fileSink.add(buffer);
          receivedBytes += buffer.length;

          print("📊 Progress: $receivedBytes / $fileSize");

          buffer.clear();

          /// STEP 3: Complete file
          if (receivedBytes >= fileSize!) {
            await fileSink.flush();
            await fileSink.close();

            print("✅ File saved: ${file!.path}");

            client.close();
            break;
          }
        }
      }
    } catch (e) {
      print("❌ Receive error: $e");
      client.close();
    }
  }

  /// Stop server
  void stopServer() {
    _server?.close();
    print("🛑 Server stopped");
  }
}