import 'dart:io';
import 'dart:convert';
import 'file_save_service.dart';

class ReceiveService {
  ServerSocket? _server;

  /// 🚀 Start server
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

  /// 🔥 Handle client (FIXED VERSION)
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

        /// 📌 STEP 1: METADATA READ
        while (!metaReceived) {
          int newlineIndex = buffer.indexOf(10);

          if (newlineIndex == -1) break;

          try {
            String metaString =
            utf8.decode(buffer.sublist(0, newlineIndex));

            final meta = jsonDecode(metaString);

            fileName = meta["fileName"];
            fileSize = meta["fileSize"];

            if (fileName == null || fileSize == null) {
              throw Exception("Invalid metadata");
            }

            print("📥 Receiving: $fileName ($fileSize bytes)");

            /// 🔥 FIXED HERE
            String path =
            await FileSaveService.getUniqueFilePath(fileName);

            file = File(path);
            fileSink = file.openWrite();

            buffer = buffer.sublist(newlineIndex + 1);
            metaReceived = true;
          } catch (e) {
            print("❌ Metadata parse error: $e");
            client.destroy();
            return;
          }
        }

        /// 📌 STEP 2: WRITE FILE
        if (metaReceived && fileSink != null && buffer.isNotEmpty) {
          int remaining = fileSize! - receivedBytes;

          List<int> writeData =
          buffer.length > remaining ? buffer.sublist(0, remaining) : buffer;

          fileSink.add(writeData);
          receivedBytes += writeData.length;

          print("📊 Progress: $receivedBytes / $fileSize");

          buffer = buffer.sublist(writeData.length);

          /// 📌 STEP 3: COMPLETE
          if (receivedBytes >= fileSize) {
            await fileSink.flush();
            await fileSink.close();

            print("✅ File saved: ${file?.path}");

            client.destroy();
            return;
          }
        }
      }
    } catch (e) {
      print("❌ Receive error: $e");
      client.destroy();
    }
  }

  /// 🛑 Stop server
  void stopServer() {
    _server?.close();
    print("🛑 Server stopped");
  }
}