import 'package:flutter/material.dart';

import '../services/transfer/receive_service.dart';
import '../services/network/mdns_broadcast_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final ReceiveService _receiveService = ReceiveService();
  final MdnsBroadcastService _broadcastService = MdnsBroadcastService();

  bool isReceiving = false;
  bool isLoading = false;

  Future<void> _startReceiving() async {
    try {
      setState(() => isLoading = true);

      await _receiveService.startServer(8080);

      await _broadcastService.startBroadcast(
        deviceName: "FileHive_Android",
        port: 8080,
      );

      if (!mounted) return;

      setState(() {
        isReceiving = true;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("📡 Receiver + mDNS started"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: $e")),
      );
    }
  }

  Future<void> _stopReceiving() async {
    try {
      setState(() => isLoading = true);

      await _broadcastService.stopBroadcast();
      await _receiveService.stopServer();

      if (!mounted) return;

      setState(() {
        isReceiving = false;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🛑 Receiver stopped"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Stop failed: $e")),
      );
    }
  }

  @override
  void dispose() {
    _broadcastService.dispose();
    _receiveService.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: isLoading ? null : () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isReceiving
                        ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                        : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isReceiving
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF3B82F6))
                          .withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isReceiving
                      ? Icons.wifi_tethering
                      : Icons.file_download_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              isReceiving ? "Waiting for Sender" : "Receive Files",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              isReceiving
                  ? "Your device is visible now.\nSender can discover this device."
                  : "Tap start to make this device ready\nfor receiving files.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                  if (isReceiving) {
                    await _stopReceiving();
                  } else {
                    await _startReceiving();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReceiving
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  isReceiving ? "Stop Receiving" : "Start Receiving",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Device Status",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isReceiving ? "Receiver Active" : "Receiver Inactive",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isReceiving
                              ? Colors.green[700]
                              : Colors.blueGrey[900],
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isReceiving
                        ? Icons.check_circle_outline
                        : Icons.power_settings_new,
                    color: isReceiving ? Colors.green : Colors.black54,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF3B82F6)),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Make sure sender and receiver are connected to the same Wi-Fi or hotspot.",
                      style: TextStyle(color: Color(0xFF1E40AF), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}