import 'dart:io';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// 🔥 Pehle se bani file import karo
import 'filehive/services/transfer/lib/services/network_info_service.dart';

class ReceiveService {
  final NetworkInfoService _networkInfoService = NetworkInfoService();

  HttpServer? _server;
  final Router _router = Router();

  // Chunks temporarily store karne ke liye
  final Map<String, List<List<int>?>> _tempChunks = {};

  // Success event emit karne ke liye
  final StreamController<String> _successController =
  StreamController<String>.broadcast();

  // Bahar se listen kar sako
  Stream<String> get onFileReceived => _successController.stream;

  // ─────────────────────────────────────────────────
  // 1. RECEIVER KA IP NIKALO
  //    NetworkInfoService se directly
  // ─────────────────────────────────────────────────
  Future<String?> getReceiverIP() async {
    return await _networkInfoService.getWifiIP();
  }

  // ─────────────────────────────────────────────────
  // 2. HTTP SERVER START KARO
  // ─────────────────────────────────────────────────
  Future<void> startServer() async {
    // IP nikalo
    String? ip = await getReceiverIP();
    if (ip == null) {
      print('IP nahi mila — server start nahi hua');
      return;
    }

    // Routes set karo
    _router.post('/upload', _handleIncomingFile);

    // Server start karo
    _server = await shelf_io.serve(
      _router.call,
      ip,
      8080,
    );

    print('✅ Receiver Server chalu: http://$ip:8080');
  }

  // ─────────────────────────────────────────────────
  // 3. INCOMING FILE HANDLE KARO
  //    onFileReceived()
  // ─────────────────────────────────────────────────
  Future<Response> _handleIncomingFile(Request request) async {
    try {
      // Headers nikalo
      String? filename     = request.headers['x-filename'];
      String? chunkIdxStr  = request.headers['x-chunk-index'];
      String? totalChunksStr = request.headers['x-total-chunks'];
      String? fileSizeStr  = request.headers['x-file-size'];
      String? checksum     = request.headers['x-checksum'];
      String? token        = request.headers['x-token'];

      // Validation
      if (filename == null ||
          chunkIdxStr == null ||
          totalChunksStr == null ||
          checksum == null) {
        return Response(400, body: 'Missing headers');
      }

      int chunkIdx    = int.parse(chunkIdxStr);
      int totalChunks = int.parse(totalChunksStr);

      // Body padho (chunk data)
      List<int> chunkData = await request.read().expand((x) => x).toList();

      // Checksum verify karo
      String calculated = md5.convert(chunkData).toString();
      if (calculated != checksum) {
        return Response(400,
            body: 'Checksum mismatch — chunk $chunkIdx resend karo');
      }

      // Chunk store karo
      _tempChunks[filename] ??= List.filled(totalChunks, null);
      _tempChunks[filename]![chunkIdx] = chunkData;

      // Sab chunks aaye?
      bool allReceived =
      _tempChunks[filename]!.every((chunk) => chunk != null);

      if (allReceived) {
        // File assemble karo aur save karo
        await saveIncomingFile(filename, totalChunks);
      }

      return Response.ok(
        jsonEncode({'status': 'ok', 'received': chunkIdx}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('_handleIncomingFile error: $e');
      return Response.internalServerError(body: 'Server error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // 4. FILE SAVE KARO
  //    saveIncomingFile()
  // ─────────────────────────────────────────────────
  Future<void> saveIncomingFile(String filename, int totalChunks) async {
    try {
      // Save path nikalo
      Directory saveDir = await getApplicationDocumentsDirectory();
      String filePath = '${saveDir.path}/FileHive/$filename';

      // Directory banao agar nahi hai
      await Directory('${saveDir.path}/FileHive')
          .create(recursive: true);

      // File write karo
      IOSink sink = File(filePath).openWrite();

      for (int i = 0; i < totalChunks; i++) {
        sink.add(_tempChunks[filename]![i]!);
      }

      await sink.flush();
      await sink.close();

      // Temp chunks clear karo
      _tempChunks.remove(filename);

      print('✅ File saved: $filePath');

      // Success emit karo
      emitSuccess(filePath);
    } catch (e) {
      print('saveIncomingFile error: $e');
    }
  }

  // ─────────────────────────────────────────────────
  // 5. SUCCESS EMIT KARO
  //    emitSuccess()
  // ─────────────────────────────────────────────────
  void emitSuccess(String filePath) {
    _successController.add(filePath);
    print('✅ emitSuccess: $filePath');
  }

  // ─────────────────────────────────────────────────
  // 6. SERVER BAND KARO
  // ─────────────────────────────────────────────────
  Future<void> stopServer() async {
    await _server?.close();
    _server = null;
    print('🛑 Receiver server band hua');
  }

  // ─────────────────────────────────────────────────
  // 7. CLEANUP
  // ─────────────────────────────────────────────────
  void dispose() {
    _successController.close();
    stopServer();
  }
}