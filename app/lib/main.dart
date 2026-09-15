import 'package:app/core/app_theme.dart';
import 'package:app/screens/common/splash_screen.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'global/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.loadTokens();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const SplashScreen(),
    );
  }
}
