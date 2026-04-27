
import 'package:app/screens/common/login_screen.dart';
import 'package:app/screens/users/main_screen.dart';
import 'package:app/services/auth_service.dart';
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

    // Load tokens from SharedPreferences
    await authService.loadTokens();

    String? token = await authService.getAccessToken();
    // String? role = AuthService.role; LATER

    // If access token missing, try refreshing
    token ??= await authService.refreshAccessToken();

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (AuthService.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 24, 39),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "भक्तिपथ",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
