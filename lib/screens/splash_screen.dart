import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.hexagon, color: AppColors.primaryPurple, size: 80),
            ),
            const SizedBox(height: 24),
            const Text('FileHive', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const Spacer(),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}