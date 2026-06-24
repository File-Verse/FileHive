import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/file_tile.dart';
import 'scanning_screen.dart';

class SendScreen extends StatelessWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: AppColors.primaryGreen, child: Icon(Icons.upload_rounded, color: Colors.white, size: 40)),
            const SizedBox(height: 24),
            const Text('Send Files', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Share files quickly and securely\nwith nearby devices.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanningScreen())),
                child: const Text('Select Files', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 32),
            const Align(alignment: Alignment.centerLeft, child: Text('Recent Files', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey))),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  FileTile(icon: Icons.image, color: Colors.blue, name: 'IMG_2024.jpg', size: '2.4 MB • jpg'),
                  FileTile(icon: Icons.picture_as_pdf, color: Colors.red, name: 'Document.pdf', size: '1.8 MB • pdf'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}