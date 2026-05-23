import 'package:filehive/routes/app_routes.dart';
import 'package:flutter/material.dart';

class RoomOptionsScreen extends StatelessWidget {
  const RoomOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Room",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create or join a room to\nshare files with multiple people.",
                style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 40),

              // --- UPDATE: Create Room Card Ab Settings Screen Par Le Jayega ---
              _buildOptionCard(
                title: "Create Room",
                subtitle: "Create a new room and\nshare the code",
                icon: Icons.add,
                bgColor: const Color(0xFFF3E8FF),
                accentColor: const Color(0xFF8B5CF6),
                onTap: () => Navigator.pushNamed(context, AppRoutes.room_settings), // Route Updated
              ),

              const SizedBox(height: 20),

              // Join Room Card (Same as before)
              _buildOptionCard(
                title: "Join Room",
                subtitle: "Join an existing room\nusing a room code",
                icon: Icons.login_rounded,
                bgColor: const Color(0xFFEFF6FF),
                accentColor: const Color(0xFF3B82F6),
                onTap: () => Navigator.pushNamed(context, AppRoutes.room_join),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: "Files"),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25), // Ripple effect properly card ke andar rahega
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: accentColor)),
                  const SizedBox(height: 8),
                  Text(subtitle, style: const TextStyle(fontSize: 15, color: Colors.black54)),
                ],
              ),
            ),
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}