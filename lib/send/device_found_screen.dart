import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DeviceFoundScreen extends StatelessWidget {
  const DeviceFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: AppColors.primaryPurple, child: Icon(Icons.check, color: Colors.white, size: 40)),
            const SizedBox(height: 24),
            const Text('1 Device Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 32),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('FileHive_Android', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Android Device'),
              trailing: const Icon(Icons.signal_cellular_alt, color: AppColors.primaryGreen),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () {},
                child: const Text('Connect', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}