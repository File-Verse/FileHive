import 'package:flutter/material.dart';
// Ensure this path exactly matches where you put app_colors.dart!
import '../../core/theme/app_colors.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // If the error was here, it means AppColors is not imported correctly.
            const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.download_rounded, color: Colors.white, size: 40)
            ),
            const SizedBox(height: 24),
            const Text(
                'Receive Files',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)
            ),
            const SizedBox(height: 8),
            const Text(
                'Your device is ready to receive\nfiles from nearby devices.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGrey)
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                onPressed: () {},
                child: const Text('Start Receiving', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Device Name', style: TextStyle(fontSize: 12, color: AppColors.textGrey))
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12)
              ),
              // REMOVED 'const' from the Row below to fix a potential "invalid constant" error
              // if AppColors isn't evaluating properly.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('FileHive_Android', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const Icon(Icons.edit, color: AppColors.textGrey, size: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}