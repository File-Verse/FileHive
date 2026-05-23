import 'package:flutter/material.dart';
// Note: Ensure karein ki folder ka naam 'onboarding' hi ho
import 'onboarding/onboarding_screen1.dart';
import 'onboarding/onboarding_screen2.dart';
import 'onboarding/onboarding_screen3.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({Key? key}) : super(key: key);

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _controller = PageController();

  void _nextPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Memory leak se bachne ke liye
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        // Physics 'Never' hai isliye button dabane par hi page badlega
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // 1. Class name 'OnboardingScreen1' hona chahiye
          OnboardingScreen1(onNext: () => _nextPage(1)),

          // 2. Class name 'OnboardingScreen2' hona chahiye
          OnboardingScreen2(onNext: () => _nextPage(2)),

          // 3. Aakhri screen (OnboardingScreen3)
          const OnboardingScreen3(),
        ],
      ),
    );
  }
}