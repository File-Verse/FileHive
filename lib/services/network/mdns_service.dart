import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';

class DiscoveredDevice {
  final String name;
  final String ip;
  final int port;

  const DiscoveredDevice({
    required this.name,
    required this.ip,
    required this.port,
  });

  @override
  String toString() {
    return 'DiscoveredDevice(name: $name, ip: $ip, port: $port)';
  }
}

class MdnsService {
  static const String serviceType = '_filehive._tcp';

  MDnsClient? _client;

  Future<List<DiscoveredDevice>> scanDevices({
    Duration scanTimeout = const Duration(seconds: 5),
    Duration resolveTimeout = const Duration(seconds: 2),
  }) async {
    final devices = <DiscoveredDevice>[];
    final client = MDnsClient();

    _client = client;

    try {
      await client.start();

      final ptrStream = client.lookup<PtrResourceRecord>(
        ResourceRecordQuery.serverPointer(serviceType),
      );

      await for (final ptr in ptrStream.timeout(scanTimeout)) {
        final device = await _resolveDevice(
          client: client,
          ptr: ptr,
          timeout: resolveTimeout,
        );

        if (device == null) continue;

        final alreadyExists = devices.any(
              (d) => d.ip == device.ip && d.port == device.port,
        );

        if (!alreadyExists) {
          devices.add(device);
          print('✅ Device Found: $device');
        }
      }
    } on TimeoutException {
      print('⏱️ mDNS scan completed');
    } catch (e) {
      print('❌ mDNS scan error: $e');
    } finally {
      client.stop();

      if (identical(_client, client)) {
        _client = null;
      }
    }

    return devices;
  }

  Future<DiscoveredDevice?> _resolveDevice({
    required MDnsClient client,
    required PtrResourceRecord ptr,
    required Duration timeout,
  }) async {
    try {
      await for (final srv in client
          .lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )
          .timeout(timeout)) {
        final ip = await _resolveIp(
          client: client,
          hostName: srv.target,
          timeout: timeout,
        );

        if (ip == null) return null;

        return DiscoveredDevice(
          name: _cleanDeviceName(ptr.domainName),
          ip: ip,
          port: srv.port,
        );
      }
    } on TimeoutException {
      print('⏱️ Resolve device timeout: ${ptr.domainName}');
    } catch (e) {
      print('❌ Resolve device error: $e');
    }

    return null;
  }

  Future<String?> _resolveIp({
    required MDnsClient client,
    required String hostName,
    required Duration timeout,
  }) async {
    try {
      await for (final ipRecord in client
          .lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(hostName),
      )
          .timeout(timeout)) {
        return ipRecord.address.address;
      }
    } on TimeoutException {
      print('⏱️ Resolve IP timeout: $hostName');
    } catch (e) {
      print('❌ Resolve IP error: $e');
    }

    return null;
  }

  String _cleanDeviceName(String domainName) {
    return domainName
        .replaceAll('.$serviceType.local', '')
        .replaceAll('.local', '')
        .trim();
  }

  void stop() {
    _client?.stop();
    _client = null;
  }
}