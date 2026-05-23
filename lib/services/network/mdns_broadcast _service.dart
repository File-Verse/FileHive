import 'package:nsd/nsd.dart';

class MdnsBroadcastService {
  // Must match MdnsService.serviceType
  static const String serviceType = '_filehive._tcp';

  Registration? _registration;

  bool get isBroadcasting => _registration != null;

  Future<void> startBroadcast({
    required String deviceName,
    required int port,
  }) async {
    if (port <= 0 || port > 65535) {
      throw ArgumentError('Invalid port: $port');
    }

    final safeName = deviceName.trim().isEmpty
        ? 'FileHive-${DateTime.now().millisecondsSinceEpoch}'
        : deviceName.trim();

    if (_registration != null) {
      await stopBroadcast();
    }

    try {
      final service = Service(
        name: safeName,
        type: serviceType,
        port: port,
      );

      _registration = await register(service);

      print('✅ FileHive mDNS broadcast started');
      print('📡 Service Type: $serviceType');
      print('📱 Device Name: $safeName');
      print('🔌 Port: $port');
      print('🌐 IP: dynamic / resolved by MdnsService');
    } catch (e) {
      _registration = null;
      print('❌ mDNS broadcast error: $e');
      rethrow;
    }
  }

  Future<void> stopBroadcast() async {
    final registration = _registration;

    if (registration == null) return;

    try {
      await unregister(registration);
      print('🛑 FileHive mDNS broadcast stopped');
    } catch (e) {
      print('❌ stopBroadcast error: $e');
    } finally {
      _registration = null;
    }
  }

  Future<void> restartBroadcast({
    required String deviceName,
    required int port,
  }) async {
    await stopBroadcast();

    await startBroadcast(
      deviceName: deviceName,
      port: port,
    );
  }

  Future<void> dispose() async {
    await stopBroadcast();
  }
}