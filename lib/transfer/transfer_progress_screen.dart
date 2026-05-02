import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransferProgressScreen extends StatelessWidget {
  final bool isSending;
  const TransferProgressScreen({super.key, required this.isSending});

  @override
  Widget build(BuildContext context) {
    Color themeColor = isSending ? AppColors.primaryGreen : AppColors.primaryBlue;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isSending ? 'Sending...' : 'Receiving...', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 40),
            LinearProgressIndicator(value: 0.75, color: themeColor, backgroundColor: themeColor.withOpacity(0.2), minHeight: 8),
            const SizedBox(height: 16),
            const Text('75%', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}