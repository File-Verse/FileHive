import 'package:filehive/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:filehive/routes/app_routes.dart'; // AppRoutes import kiya

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Icon section - Groups/Sharing
            const Icon(
                Icons.groups_rounded,
                size: 200,
                color: Color(0xFF4F46E5)
            ),

            const SizedBox(height: 40),

            // Text Section
            const Text(
                "Share With Everyone",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                "Create rooms and share files with multiple people at once.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),

            const Spacer(),

            // "Get Started" Button
            _buildGetStartedButton(context),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Final Button Logic
  Widget _buildGetStartedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: () {
          // Home Screen par bhej rahe hain aur purani sari screens hata rahe hain
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Get Started",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                SizedBox(width: 8),
                Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}