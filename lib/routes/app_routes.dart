import 'package:flutter/material.dart';

// --- ALL SCREENS IMPORTS ---
import 'package:filehive/screens/splash_screen.dart';
import 'package:filehive/screens/onboarding_wrapper.dart';
import 'package:filehive/screens/home/home_screen.dart';
import 'package:filehive/screens/files_screen.dart';
import 'package:filehive/screens/file_selection_screen.dart';
import 'package:filehive/screens/scanning_screen.dart';
import 'package:filehive/screens/receive/receive_screen.dart';
import 'package:filehive/screens/send_progress_screen.dart';

// --- FOLDER SPECIFIC IMPORTS ---
import 'package:filehive/screens/send_screen.dart';
import 'package:filehive/screens/send/device_found_screen.dart';
import 'package:filehive/screens/transfer/transfer_complete_screen.dart';

// --- ROOM IMPORTS ---
import 'package:filehive/screens/room/room_options_screen.dart';
import 'package:filehive/screens/room/create_room_settings_screen.dart'; // Naya Settings Screen Import
import 'package:filehive/screens/room/create_room_screen.dart';
import 'package:filehive/screens/room/join_room_screen.dart';

class AppRoutes {
  // --- ROUTE CONSTANTS ---
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String files = '/files';
  static const String send = '/send';
  static const String selection = '/selection';
  static const String scanning = '/scanning';
  static const String receive = '/receive';
  static const String deviceFound = '/device_found';
  static const String sendProgress = '/send_progress';
  static const String transferComplete = '/transfer_complete';

  // Room Routes
  static const String room_set = '/room_set';
  static const String room_settings = '/room_settings'; // Naya Route Constant
  static const String room_create = '/room_create';
  static const String room_join = '/room_join';

  // --- MAP OF ROUTES ---
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingWrapper(),
      home: (context) => const HomeScreen(),
      files: (context) => const FilesScreen(),
      send: (context) => const SendScreen(),
      selection: (context) => const FileSelectionScreen(),
      scanning: (context) => const ScanningScreen(),
      receive: (context) => const ReceiveScreen(),
      deviceFound: (context) => const DeviceFoundScreen(),
      sendProgress: (context) => const SendProgressScreen(),
      transferComplete: (context) => const TransferCompleteScreen(),

      // Room Screens Registration
      room_set: (context) => const RoomOptionsScreen(),
      room_settings: (context) => const CreateRoomSettingsScreen(), // Registered Here
      room_create: (context) => const CreateRoomScreen(),
      room_join: (context) => const JoinRoomScreen(),
    };
  }

  // --- NAVIGATION HELPERS ---
  static void goToRoom(BuildContext context) {
    Navigator.pushNamed(context, room_set);
  }

  static void goToRoomSettings(BuildContext context) {
    Navigator.pushNamed(context, room_settings);
  }

  static void goToDeviceFound(BuildContext context) {
    Navigator.pushNamed(context, deviceFound);
  }

  static void goToSendProgress(BuildContext context) {
    Navigator.pushNamed(context, sendProgress);
  }

  static void goToTransferComplete(BuildContext context) {
    Navigator.pushNamed(context, transferComplete);
  }
}