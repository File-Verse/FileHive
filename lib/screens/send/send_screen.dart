import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filehive/core/theme/app_colors.dart';
import 'package:filehive/widgets/file_tile.dart';
import 'package:filehive/services/transfer/send_service.dart'; // <-- apna correct path likho
import 'package:filehive/screens/send/file_selected_screen.dart'; // <-- apna path

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final SendService _sendService = SendService();

  Future<void> _selectFiles() async {
    final List<File> files = await _sendService.pickFiles();

    if (files.isEmpty) return;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FileSelectionScreen(
          selectedFiles: files,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryGreen,
              child: Icon(
                Icons.upload_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Send Files",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Share files quickly and securely\nwith nearby devices.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                onPressed: _selectFiles,

                child: const Text(
                  "Select Files",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Files",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textGrey,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: const [
                  FileTile(
                    icon: Icons.image,
                    color: Colors.blue,
                    name: "IMG_2024.jpg",
                    size: "2.4 MB • jpg",
                  ),
                  FileTile(
                    icon: Icons.picture_as_pdf,
                    color: Colors.red,
                    name: "Document.pdf",
                    size: "1.8 MB • pdf",
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