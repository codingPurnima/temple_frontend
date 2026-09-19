import 'package:app/core/app_theme.dart';
import 'package:app/helper/session.dart';
import 'package:app/screens/common/login_screen.dart';
import 'package:app/screens/users/main_screen.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/profile_service.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final authService = AuthService();

    await authService.loadToken();

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    final token = await authService.getAccessToken();

    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
      return;
    }

    try {
      final profile = await ProfileService().getProfile();

      Session.role = profile["role"];

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.warmGold, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Splash.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              " मन्दिरम् ",
              style: TextStyle(
                fontFamily: 'TiroDevanagariHindi',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 48,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.warmGold.withValues(alpha: 0.4)),
                  bottom: BorderSide(color: AppTheme.warmGold.withValues(alpha: 0.4)),
                ),
              ),
              child: const Text(
                "। श्रीमते रामानुजाय नमः ।",
                style: TextStyle(
                  fontFamily: 'TiroDevanagariHindi',
                  color: AppTheme.warmGoldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
