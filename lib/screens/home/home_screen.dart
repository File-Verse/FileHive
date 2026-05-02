import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/action_card.dart';
import '../../send/send_screen.dart';
import '../../room/room_options_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hi, Welcome! 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text('What would you like to do today?', style: TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 32),
            ActionCard(
              title: 'Send',
              subtitle: 'Share files quickly and securely',
              iconData: Icons.upload_rounded,
              iconColor: AppColors.primaryGreen,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendScreen())),
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'Receive',
              subtitle: 'Receive files from nearby devices',
              iconData: Icons.download_rounded,
              iconColor: AppColors.primaryBlue,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            ActionCard(
              title: 'Room',
              subtitle: 'Create or join a room to share files',
              iconData: Icons.groups_rounded,
              iconColor: AppColors.primaryPurple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomOptionsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}