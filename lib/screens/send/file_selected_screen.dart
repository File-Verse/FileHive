import 'dart:io';

import 'package:flutter/material.dart';
import 'package:filehive/routes/app_routes.dart';

class FileSelectionScreen extends StatelessWidget {
  final List<File> selectedFiles;

  const FileSelectionScreen({
    super.key,
    required this.selectedFiles,
  });

  double get totalSize {
    int bytes = 0;
    for (final file in selectedFiles) {
      bytes += file.lengthSync();
    }
    return bytes / (1024 * 1024);
  }

  IconData _getIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;

      case 'pdf':
        return Icons.picture_as_pdf;

      case 'ppt':
      case 'pptx':
        return Icons.slideshow;

      case 'mp4':
      case 'mkv':
      case 'avi':
        return Icons.movie;

      case 'mp3':
      case 'wav':
        return Icons.music_note;

      case 'doc':
      case 'docx':
        return Icons.description;

      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.blue;

      case 'pdf':
        return Colors.red;

      case 'ppt':
      case 'pptx':
        return Colors.orange;

      case 'mp4':
        return Colors.purple;

      case 'mp3':
        return Colors.green;

      default:
        return Colors.grey;
    }
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
          onPressed: () => Navigator.pop(context),
        ),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${selectedFiles.length} Files Selected",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              "${totalSize.toStringAsFixed(2)} MB",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: selectedFiles.length,
              itemBuilder: (context, index) {
                final file = selectedFiles[index];

                final fileName = file.path.split('/').last;

                final extension = fileName.contains('.')
                    ? fileName.split('.').last
                    : "";

                final size =
                (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);

                return _buildSelectedFileTile(
                  fileName,
                  "$size MB",
                  _getIcon(extension),
                  _getColor(extension),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.scanning,
                    arguments: selectedFiles,
                  );
                },
                icon: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "Send Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFileTile(
      String name,
      String size,
      IconData icon,
      Color color,
      ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(name),
      subtitle: Text(size),
      trailing: const Icon(
        Icons.check_circle,
        color: Colors.green,
      ),
    );
  }
}