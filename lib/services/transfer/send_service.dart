import 'package:flutter/foundation.dart';
import '../network/mdns_service.dart';
import '../network/network_info_service.dart';

class SendService {
  final MdnsService _mdnsService;
  final NetworkInfoService _networkInfoService;

  SendService(this._mdnsService, this._networkInfoService);

  Future<void> initializeSending() async {
    try {
      debugPrint("Initializing Send Service...");

      // 1. Get the local IP Address
      try {
        final ip = await _networkInfoService.getLocalIpAddress();
        debugPrint("Current IP: $ip");
      } catch (e) {
        debugPrint("Could not get IP: $e");
      }

      // 2. Start scanning for mDNS devices
      try {
        // scanDevices() returns a Future<List<DiscoveredDevice>>
        // so we can await it and store the results!
        final devices = await _mdnsService.scanDevices();
        debugPrint("mDNS Service started successfully. Found ${devices.length} devices.");
      } catch (e) {
        debugPrint("Could not start mDNS: $e");
      }

    } catch (e) {
      debugPrint("Error initializing SendService: $e");
    }
  }

  // Method to stop the service
  void stopSending() {
    debugPrint("Stopping Send Service...");
    _mdnsService.stop();
  }
}