import 'package:filehive/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:filehive/routes/app_routes.dart'; // AppRoutes import kiya

class OnboardingScreen1 extends StatelessWidget { // Naam OnboardingScreen1 kar diya
  final VoidCallback onNext;
  const OnboardingScreen1({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home), // AppRoutes use kiya
                child: const Text(
                    "Skip",
                    style: TextStyle(color: Color(0xFF1A437E), fontWeight: FontWeight.bold)
                ),
              ),
            ),
            const Spacer(),

            // Icon section
            const Icon(
                Icons.phonelink_setup_rounded,
                size: 180,
                color: Color(0xFF6366F1)
            ),

            const SizedBox(height: 40),

            // Text Section
            const Text(
                "Share Files Instantly",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                "Send and receive files to any device near you with lightning speed.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),

            const Spacer(),

            // Custom Next Button
            _buildNextButton(onNext),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Common Button Widget
  Widget _buildNextButton(VoidCallback onTap, {String text = "Next"}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30), // Ripple effect ke liye
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}