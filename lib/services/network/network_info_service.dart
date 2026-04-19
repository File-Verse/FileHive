import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

class NetworkInfoService {
  final NetworkInfo _networkInfo = NetworkInfo();

  // ─── Get WiFi IP ───────────────────────────────────────────
  Future<String?> getWifiIP() async {
    try {
      String? ip = await _networkInfo.getWifiIP();
      return ip; // e.g. "192.168.43.100"
    } catch (e) {
      print('getWifiIP error: $e');
      return null;
    }
  }
}