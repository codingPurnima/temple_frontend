import 'package:app/core/app_theme.dart';
import 'package:app/screens/common/login_screen.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/app_drawer.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('प्रस्थान की पुष्टि / Confirm Logout'),
          content: const Text('क्या आप सचमुच लॉगआउट करना चाहते हैं?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('रद्द करें / Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (shouldLogout != true) return;
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await AuthService().logout();

      if (!mounted) return;

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Center(child: Text("Failed to logout. Please Retry")),
        ),
      );
    }
  }

  Future<String> loadText() async {
    return await rootBundle.loadString('assets/text/home_screen.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("भक्तिपथ"),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () async {
              await _handleLogout(context);
            },
            icon: const Icon(Icons.logout_rounded, size: 22),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.saffronLight,
              border: Border(
                top: BorderSide(color: AppTheme.warmGold.withValues(alpha: 0.3), width: 1),
                bottom: BorderSide(color: AppTheme.warmGold.withValues(alpha: 0.5), width: 1.5),
              ),
            ),
            alignment: Alignment.center,
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "॥ श्रीमते रामानुजाय नमः ॥",
                style: TextStyle(
                  fontFamily: 'TiroDevanagariHindi',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppTheme.saffronAccent,
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Banner Carousel with elegant rounded borders and shadow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: 380,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 4),
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                  ),
                  items: [
                    'assets/images/DashboardCarousel/header1gl.png',
                    'assets/images/DashboardCarousel/header1rr.jpeg',
                    'assets/images/DashboardCarousel/header2gl.png',
                    'assets/images/DashboardCarousel/header2rr.jpeg',
                    'assets/images/DashboardCarousel/header3gl.png',
                    'assets/images/DashboardCarousel/header3rr.jpeg',
                    'assets/images/DashboardCarousel/header4rr.jpeg',
                  ].map((path) {
                    return Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reading Section Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<String>(
              future: loadText(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: AppLoadingView(),
                  );
                } else if (snapshot.hasError) {
                  return AppErrorView(
                    message: "संदेश लोड नहीं हो सका: ${snapshot.error}",
                  );
                } else if (snapshot.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppTheme.saffronAccent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "सन्देश / विचार",
                              style: TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppTheme.cardBorder, height: 1),
                        const SizedBox(height: 14),
                        Text(
                          snapshot.data!,
                          style: const TextStyle(
                            fontFamily: 'TiroDevanagariHindi',
                            fontSize: 16,
                            height: 1.8,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  );
                } else {
                  return const AppEmptyView(
                    title: "कोई सामग्री उपलब्ध नहीं है",
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
