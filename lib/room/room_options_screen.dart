import 'package:flutter/material.dart';

// IMPORTANT: Check your pubspec.yaml file on line 1.
// If your project is named something other than "filehive" (like "FileHive" or "myapp"),
// replace the word "filehive" below with exactly what is in your pubspec.yaml.
import 'package:filehive/core/theme/app_colors.dart';
import 'package:filehive/widgets/action_card.dart';

import 'create_room_screen.dart';
import 'join_room_screen.dart';

class RoomOptionsScreen extends StatelessWidget {
  const RoomOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primaryPurple,
                child: Icon(Icons.groups_rounded, color: Colors.white, size: 40)
            ),
            const SizedBox(height: 24),
            const Text('Room', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('Create or join a room to\nshare files with multiple people.', style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 32),
            ActionCard(
              title: 'Create Room',
              subtitle: 'Create a new room and share the code',
              iconData: Icons.add,
              iconColor: AppColors.primaryPurple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRoomScreen())),
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'Join Room',
              subtitle: 'Join an existing room using a room code',
              iconData: Icons.login,
              iconColor: AppColors.primaryBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinRoomScreen())),
            ),
          ],
        ),
      ),
    );
  }
}