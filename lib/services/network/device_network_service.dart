import 'dart:io';
import 'package:flutter/foundation.dart';

class DeviceNetworkService {
  /// Returns the device's local IPv4 address (e.g. 192.168.x.x).
  /// Falls back to '127.0.0.1' (localhost) if no LAN address is found.
  Future<String> getLocalIp() async {
    try {
      for (final interface in await NetworkInterface.list()) {
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      debugPrint('DeviceNetworkService: getLocalIp error: $e');
    }
    return '127.0.0.1';
  }
}
