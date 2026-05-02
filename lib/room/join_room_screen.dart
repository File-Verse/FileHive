import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'room_details_screen.dart';

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.login, size: 80, color: AppColors.primaryBlue),
            const SizedBox(height: 16),
            const Text('Join Room', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Enter the room code provided\nby the creator.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 40),
            const Align(alignment: Alignment.centerLeft, child: Text('Enter Room Code', style: TextStyle(fontSize: 12, color: AppColors.textGrey))),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. ABCD12',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomDetailsScreen())),
                child: const Text('Join Room', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}