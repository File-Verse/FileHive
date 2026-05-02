import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransferCompleteScreen extends StatelessWidget {
  const TransferCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, backgroundColor: AppColors.primaryGreen, child: Icon(Icons.check, color: Colors.white, size: 60)),
            const SizedBox(height: 24),
            const Text('Transfer Complete!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('1 file transferred successfully.', style: TextStyle(color: AppColors.textGrey)),
            const Spacer(),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.pop(context), child: const Text('Open File', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}