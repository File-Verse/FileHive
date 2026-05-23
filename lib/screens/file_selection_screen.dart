import 'package:flutter/material.dart';
import 'package:filehive/routes/app_routes.dart'; // Import zaroori hai

class FileSelectionScreen extends StatelessWidget {
  const FileSelectionScreen({Key? key}) : super(key: key);

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("3 Files Selected", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("12.4 MB", style: TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSelectedFileTile("IMG_2024.jpg", "2.4 MB", Icons.image, Colors.blue),
                _buildSelectedFileTile("Document.pdf", "1.8 MB", Icons.picture_as_pdf, Colors.red),
                _buildSelectedFileTile("Presentation.pptx", "5.2 MB", Icons.slideshow, Colors.orange),
              ],
            ),
          ),

          // --- SEND NOW BUTTON ---
          Padding(
            padding: const EdgeInsets.all(25),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  // YE LINE SCANNING SCREEN KHOL DEGI
                  Navigator.pushNamed(context, AppRoutes.scanning);
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text("Send Now", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFileTile(String name, String size, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(name),
      subtitle: Text(size),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }
}