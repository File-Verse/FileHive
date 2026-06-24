import 'package:flutter/material.dart';
import 'package:filehive/routes/app_routes.dart';

class CreateRoomSettingsScreen extends StatefulWidget {
  const CreateRoomSettingsScreen({Key? key}) : super(key: key);

  @override
  State<CreateRoomSettingsScreen> createState() => _CreateRoomSettingsScreenState();
}

class _CreateRoomSettingsScreenState extends State<CreateRoomSettingsScreen> {
  double _memberLimit = 10;
  double _storageLimit = 500; // in MB
  final TextEditingController _roomNameController = TextEditingController(text: "Project Alpha");

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
        title: const Text("Room Settings", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 1. Header Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.groups_rounded, size: 50, color: Color(0xFF6366F1)),
              ),
            ),

            const SizedBox(height: 30),

            // 2. Room Name Input
            const Text("Room Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            TextField(
              controller: _roomNameController,
              decoration: InputDecoration(
                hintText: "Enter room name...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.edit_note, color: Color(0xFF6366F1)),
              ),
            ),

            const SizedBox(height: 30),

            // 3. Member Limit Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Member Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${_memberLimit.toInt()} People", style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _memberLimit,
              min: 2,
              max: 50,
              activeColor: const Color(0xFF6366F1),
              onChanged: (value) => setState(() => _memberLimit = value),
            ),

            const SizedBox(height: 20),

            // 4. Storage Limit Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Storage Limit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${(_storageLimit / 1024).toStringAsFixed(1)} GB", style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _storageLimit,
              min: 100,
              max: 5120, // 5GB
              activeColor: const Color(0xFF3B82F6),
              onChanged: (value) => setState(() => _storageLimit = value),
            ),

            const SizedBox(height: 40),

            // 5. Info Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.security, color: Colors.green),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "This room will be encrypted. Only members with the code can join.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 6. Create Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Agla Step: Create Room Success Screen (Jo aapne image di thi)
                  Navigator.pushNamed(context, AppRoutes.room_create);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: const Text(
                  "Create Room Now",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}