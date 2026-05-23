import 'package:flutter/material.dart';
import 'package:filehive/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() { _selectedIndex = index; });
    if (index == 1) Navigator.pushNamed(context, AppRoutes.files);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('FileHive', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150')),
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("Hi, Welcome! 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("What would you like to do today?", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 25),

              // 1. SEND CARD
              _buildActionTile(
                title: "Send",
                subtitle: "Share files quickly and securely",
                icon: Icons.upload_rounded,
                color: const Color(0xFF22C55E),
                onTap: () => Navigator.pushNamed(context, AppRoutes.send),
              ),
              const SizedBox(height: 15),

              // 2. RECEIVE CARD (Update: Navigation Linked)
              _buildActionTile(
                title: "Receive",
                subtitle: "Receive files from nearby devices",
                icon: Icons.download_rounded,
                color: const Color(0xFF3B82F6),
                onTap: () => Navigator.pushNamed(context, AppRoutes.receive),
              ),
              const SizedBox(height: 15),

              // 3. ROOM CARD
              _buildActionTile(
                title: "Room",
                subtitle: "Create or join a room",
                icon: Icons.groups_rounded,
                color: const Color(0xFF8B5CF6),
                onTap: ()=> Navigator.pushNamed(context, AppRoutes.room_set) ,
              ),

              const SizedBox(height: 30),
              const Text("Recent Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildFileItem("IMG_2024.jpg", "2.4 MB", Icons.image, Colors.blue),
              _buildFileItem("Document.pdf", "1.8 MB", Icons.picture_as_pdf, Colors.red),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: "Files"),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: "Activity"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildActionTile({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(String name, String size, IconData icon, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(size),
      trailing: const Icon(Icons.more_vert),
    );
  }
}