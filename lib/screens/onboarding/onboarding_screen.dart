import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _data = [
    {"title": "Share Files Instantly", "desc": "Send and receive files to any device near you with lightning speed."},
    {"title": "Secure & Private", "desc": "Your files are encrypted and transferred securely over a local network."},
    {"title": "Share With Everyone", "desc": "Create rooms and share files with multiple people at once."}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout())), child: const Text("Skip", style: TextStyle(color: AppColors.primaryPurple)))
      ]),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.important_devices, size: 120, color: AppColors.primaryPurple),
                      const SizedBox(height: 40),
                      Text(_data[index]["title"]!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(height: 16),
                      Text(_data[index]["desc"]!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textGrey)),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _currentPage == 2 ? AppColors.primaryBlue : AppColors.primaryPurple),
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  } else {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainLayout()));
                  }
                },
                child: Text(_currentPage == 2 ? 'Get Started →' : 'Next →', style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}