import 'package:flutter/material.dart';

class FilesScreen extends StatelessWidget {
  const FilesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Files", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_rounded, size: 100, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text("Your files will appear here", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}