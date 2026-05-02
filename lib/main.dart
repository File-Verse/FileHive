import 'package:flutter/material.dart';
// Foolproof absolute import paths:
import 'package:filehive/core/theme/app_colors.dart';
import 'package:filehive/screens/splash_screen.dart';

void main() {
  runApp(const FileHiveApp());
}

class FileHiveApp extends StatelessWidget {
  const FileHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FileHive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
          titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}