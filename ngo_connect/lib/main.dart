import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'screens/landing_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: NgoConnectApp(),
    ),
  );
}

class NgoConnectApp extends StatelessWidget {
  const NgoConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGO Connect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LandingPage(),
    );
  }
}
