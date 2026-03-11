import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CenroApp());
}

/// Certificate of Inspection - Offline mobile app
/// City Government of Puerto Princesa - Bantay Dagat Section
class CenroApp extends StatelessWidget {
  const CenroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Certificate of Inspection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashScreen(),
    );
  }
}
