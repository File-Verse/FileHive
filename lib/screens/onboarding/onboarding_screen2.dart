import 'package:flutter/material.dart';

class OnboardingScreen2 extends StatelessWidget { // Name updated to match Wrapper
  final VoidCallback onNext;
  const OnboardingScreen2({Key? key, required this.onNext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Icon section - Secure Shield
            const Icon(
                Icons.shield_rounded,
                size: 180,
                color: Color(0xFF3F51B5)
            ),

            const SizedBox(height: 40),

            // Text Section
            const Text(
                "Secure & Private",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                "Your files are encrypted and transferred securely over a local network.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),

            const Spacer(),

            // Next Button
            _buildNextButton(onNext),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Reuse same button logic for consistency
  Widget _buildNextButton(VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
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
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}