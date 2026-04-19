import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoService {
  final NetworkInfo _networkInfo = NetworkInfo();

  // ─────────────────────────────────────────────
  // CROSS PLATFORM IP GETTER
  // ─────────────────────────────────────────────
  Future<String?> getWifiIP() async {
    try {
      // ✅ MOBILE (Android / iOS)
      if (Platform.isAndroid || Platform.isIOS) {
        String? ip = await _networkInfo.getWifiIP();
        if (ip != null && ip.isNotEmpty) {
          return ip;
        }
      }

      // ✅ DESKTOP (Windows / macOS / Linux)
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          // IPv4 lo aur loopback skip karo
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback) {
            return addr.address;
          }
        }
      }

      return null;
    } catch (e) {
      print('getWifiIP error: $e');
      return null;
    }
  }
}