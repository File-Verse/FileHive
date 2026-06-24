import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'device_found_screen.dart';

class ScanningScreen extends StatelessWidget {
  const ScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DeviceFoundScreen())),
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryPurple.withOpacity(0.1)),
                child: Center(
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryPurple.withOpacity(0.3)),
                    child: const Icon(Icons.wifi_tethering, size: 40, color: AppColors.primaryPurple),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Scanning for devices...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 40),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}