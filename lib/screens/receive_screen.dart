import 'package:flutter/material.dart';

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. Blue Circular Download Icon (As per image_2e6990.png)
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.file_download_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 2. Title and Subtitle
            const Text(
              "Receive Files",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your device is ready to receive\nfiles from nearby devices.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),

            const SizedBox(height: 40),

            // 3. Start Receiving Button
            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton(
                onPressed: () {
                  // Scanning animation screen par bhejne ke liye
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF3B82F6).withOpacity(0.4),
                ),
                child: const Text(
                  "Start Receiving",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 4. Device Name Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Device Name",
                          style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text("FileHive_Android",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                    ],
                  ),
                  const Icon(Icons.edit_outlined, color: Colors.black54),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 5. Bottom Info Box (Security/Note)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF3B82F6)),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Make sure the sender is nearby and connected.",
                      style: TextStyle(color: Color(0xFF1E40AF), fontSize: 14),
                    ),
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