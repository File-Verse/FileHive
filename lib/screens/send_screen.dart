import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Iske liye 'flutter pub add file_picker' chalana zaroori hai
import 'package:filehive/routes/app_routes.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({Key? key}) : super(key: key);

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {

  // --- File Picker Logic ---
  Future<void> _handleFileSelection() async {
    try {
      // 1. Mobile ka native file picker open hoga
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Multiple files select karne ke liye
        type: FileType.any,  // Har tarah ki file (PDF, Image, Video) allow hai
      );

      if (result != null && result.files.isNotEmpty) {
        // 2. Agar user ne file select kar li, toh selection screen par bhej do
        if (!mounted) return;
        Navigator.pushNamed(context, AppRoutes.selection);
      } else {
        // User ne bina select kiye back kar diya
        debugPrint("User cancelled the picker");
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
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
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Big Circular Send Icon (image_3968fc.png se match kiya hua)
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.upload_rounded,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Send Files",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Share files quickly and securely\nwith nearby devices.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // --- Select Files Button (Triggering Picker) ---
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: _handleFileSelection, // Picker function call
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0xFF22C55E).withOpacity(0.4),
                  ),
                  child: const Text(
                    "Select Files",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Recent Files Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Files",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.selection);
                    },
                    child: const Text(
                      "See All",
                      style: TextStyle(color: Color(0xFF1A437E)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              _buildFileTile("IMG_2024.jpg", "2.4 MB • jpg", Icons.image, Colors.blue),
              _buildFileTile("Document.pdf", "1.8 MB • pdf", Icons.picture_as_pdf, Colors.red),
              _buildFileTile("Presentation.pptx", "5.2 MB • pptx", Icons.slideshow, Colors.orange),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTile(String name, String info, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(info),
        trailing: const Icon(Icons.more_vert, color: Colors.grey),
      ),
    );
  }
}