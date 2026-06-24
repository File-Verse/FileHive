import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/file_tile.dart';

class RoomDetailsScreen extends StatelessWidget {
  const RoomDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            // The editor spellchecker might flag "ABCD12" as a typo. You can safely ignore it!
            Text('Room: ABCD12', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('3 Members • 2 Files', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ],
        ),
        centerTitle: true,
        actions: const [Icon(Icons.more_vert), SizedBox(width: 16)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Members', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                Text('See All', style: TextStyle(color: AppColors.primaryPurple, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            _buildMember('You (Owner)', true),
            _buildMember('Rahul', false),
            _buildMember('Priya', false),
            const SizedBox(height: 32),
            const Text('Files', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textGrey)),
            const SizedBox(height: 16),
            // FIXED: Removed const from Expanded, added const to the children array
            Expanded(
              child: ListView(
                children: const [
                  FileTile(icon: Icons.picture_as_pdf, color: Colors.red, name: 'Document.pdf', size: '1.8 MB • pdf'),
                  FileTile(icon: Icons.image, color: Colors.blue, name: 'IMG_2024.jpg', size: '2.4 MB • jpg'),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMember(String name, bool isOwner) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white, size: 20)
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              // UPDATED: Replaced .withOpacity() with .withValues(alpha: ...)
              color: isOwner
                  ? AppColors.primaryPurple.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
                isOwner ? 'Owner' : 'Member',
                style: TextStyle(
                    fontSize: 12,
                    color: isOwner ? AppColors.primaryPurple : AppColors.textGrey
                )
            ),
          )
        ],
      ),
    );
  }
}