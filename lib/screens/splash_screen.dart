import 'package:filehive/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:filehive/routes/app_routes.dart'; // 1. Routes file import karein

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // 2. '/onboardingh' ki spelling sahi karein ya AppRoutes use karein
        // Sabse best hai AppRoutes use karna taaki spelling galti na ho
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0F0817),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -50,
              child: _buildGlowCircle(300, const Color(0xFF1F1230)),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _buildGlowCircle(250, const Color(0xFF2E1A47)),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    child: const Stack( // Constant optimization
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.hexagon_rounded,
                          size: 110,
                          color: Color(0xFF8B5CF6),
                        ),
                        Icon(
                          Icons.hexagon_outlined,
                          size: 110,
                          color: Colors.white24,
                        ),
                        Icon(
                          Icons.hexagon,
                          size: 40,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'File',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins', // Font ensure karein
                          ),
                        ),
                        TextSpan(
                          text: 'Hive',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B5CF6),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Fast • Secure • Simple',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        // Yahan aap chaho toh ek LinearProgressIndicator bhi daal sakte ho
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.4),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}