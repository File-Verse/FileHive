import 'package:flutter/material.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({Key? key}) : super(key: key);

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Radar animation ke liye controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Loop mein chalega
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Radar Animation (image_2e77d8.png jaisa)
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRadarCircle(1.0),
                        _buildRadarCircle(0.7),
                        _buildRadarCircle(0.4),
                        // Center dot
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF6366F1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 60),

              // Text Content
              const Text(
                "Scanning for devices...",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Make sure the receiver is nearby\nand has FileHive open.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarCircle(double delay) {
    double value = (_controller.value + delay) % 1.0;
    return Opacity(
      opacity: 1.0 - value,
      child: Container(
        width: 250 * value,
        height: 250 * value,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
    );
  }
}