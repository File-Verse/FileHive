import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoService {
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Current device ka local/private IPv4 address.
  /// Mobile par network_info_plus try karega.
  /// Desktop par NetworkInterface.list() se IP nikalega.
  Future<String?> getLocalIpAddress() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final wifiIp = await _networkInfo.getWifiIP();

        if (_isValidPrivateIp(wifiIp)) {
          return wifiIp;
        }
      }

      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      for (final interface in interfaces) {
        if (_isBadInterfaceName(interface.name)) {
          continue;
        }

        for (final address in interface.addresses) {
          final ip = address.address;

          if (_isValidPrivateIp(ip)) {
            return ip;
          }
        }
      }

      return null;
    } catch (e) {
      print('❌ getLocalIpAddress error: $e');
      return null;
    }
  }

  /// WiFi SSID/name
  Future<String?> getWifiName() async {
    try {
      return await _networkInfo.getWifiName();
    } catch (e) {
      print('❌ getWifiName error: $e');
      return null;
    }
  }

  /// Gateway IP usually router/hotspot IP hota hai.
  Future<String?> getGatewayIpAddress() async {
    try {
      final gatewayIp = await _networkInfo.getWifiGatewayIP();

      if (_isValidPrivateIp(gatewayIp)) {
        return gatewayIp;
      }

      return null;
    } catch (e) {
      print('❌ getGatewayIpAddress error: $e');
      return null;
    }
  }

  /// Example:
  /// 192.168.1.45 -> 192.168.1
  Future<String?> getNetworkBase() async {
    final ip = await getLocalIpAddress();

    if (ip == null) return null;

    final lastDotIndex = ip.lastIndexOf('.');

    if (lastDotIndex == -1) return null;

    return ip.substring(0, lastDotIndex);
  }

  /// Example:
  /// 192.168.1.45 -> 192.168.1.1
  Future<String?> guessGatewayIpAddress() async {
    final base = await getNetworkBase();

    if (base == null) return null;

    return '$base.1';
  }

  /// Private IP ranges:
  /// 10.0.0.0/8
  /// 172.16.0.0 - 172.31.255.255
  /// 192.168.0.0/16
  bool _isValidPrivateIp(String? ip) {
    if (ip == null || ip.isEmpty) return false;

    final parts = ip.split('.');

    if (parts.length != 4) return false;

    final first = int.tryParse(parts[0]);
    final second = int.tryParse(parts[1]);
    final third = int.tryParse(parts[2]);
    final fourth = int.tryParse(parts[3]);

    if (first == null || second == null || third == null || fourth == null) {
      return false;
    }

    if (first < 0 ||
        first > 255 ||
        second < 0 ||
        second > 255 ||
        third < 0 ||
        third > 255 ||
        fourth < 0 ||
        fourth > 255) {
      return false;
    }

    return first == 10 ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168);
  }

  /// Desktop par virtual/VPN adapters wrong IP de sakte hain.
  bool _isBadInterfaceName(String name) {
    final lowerName = name.toLowerCase();

    return lowerName.contains('virtual') ||
        lowerName.contains('vmware') ||
        lowerName.contains('virtualbox') ||
        lowerName.contains('docker') ||
        lowerName.contains('wsl') ||
        lowerName.contains('loopback') ||
        lowerName.contains('tailscale') ||
        lowerName.contains('zerotier') ||
        lowerName.contains('hyper-v') ||
        lowerName.contains('bluetooth');
  }
}