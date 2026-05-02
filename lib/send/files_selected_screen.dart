import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'scanning_screen.dart';

class FilesSelectedScreen extends StatelessWidget {
  const FilesSelectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3 Files Selected', style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Clear All', style: TextStyle(color: AppColors.textGrey)))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSelectedFile(Icons.image, Colors.blue, 'IMG_2024.jpg', '2.4 MB • jpg'),
                  _buildSelectedFile(Icons.picture_as_pdf, Colors.red, 'Document.pdf', '1.8 MB • pdf'),
                  _buildSelectedFile(Icons.present_to_all, Colors.orange, 'Presentation.pptx', '5.2 MB • pptx'),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanningScreen())),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Send Now', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFile(IconData icon, Color color, String name, String size) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
      subtitle: Text(size, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
      trailing: const Icon(Icons.check_circle, color: AppColors.primaryGreen),
    );
  }
}