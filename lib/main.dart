import 'package:flutter/material.dart';
import 'routes/app_routes.dart'; // Nayi routes file ko yahan import kiya

void main() {
  runApp(const FileHiveApp());
}

class FileHiveApp extends StatelessWidget {
  const FileHiveApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileHive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Blue/Indigo theme jo aapke screens se match kare
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        fontFamily: 'Poppins',
      ),

      // Purani routes list hata kar AppRoutes ka use kiya
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.getRoutes(),
    );
  }
}