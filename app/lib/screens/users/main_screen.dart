import 'package:app/core/app_theme.dart';
import 'package:app/screens/common/login_screen.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/content_service.dart';
import 'package:app/widgets/app_drawer.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
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
  final ContentService _contentService = ContentService();

  // Bundled fallback assets for the carousel
  static const List<String> _bundledCarouselImages = [
    'assets/images/DashboardCarousel/header1gl.png',
    'assets/images/DashboardCarousel/header1rr.jpeg',
    'assets/images/DashboardCarousel/header2gl.png',
    'assets/images/DashboardCarousel/header2rr.jpeg',
    'assets/images/DashboardCarousel/header3gl.png',
    'assets/images/DashboardCarousel/header3rr.jpeg',
    'assets/images/DashboardCarousel/header4rr.jpeg',
  ];

  static const String _defaultTitle = "सन्देश / विचार";

  List<String> _carouselImages = [];
  String _title = _defaultTitle;
  String? _subtitle;
  String? _content;
  bool _isLoadingContent = true;

  @override
  void initState() {
    super.initState();
    _loadInitialContent();
  }

  Future<void> _loadInitialContent() async {
    // 1. Preload bundled text fallback so screen is immediately readable
    try {
      final bundledText = await rootBundle.loadString('assets/text/home_screen.txt');
      if (mounted) {
        setState(() {
          _content = bundledText.trim();
        });
      }
    } catch (_) {}

    // 2. Fetch dynamic content from backend
    await _fetchRemoteContent();
  }

  Future<void> _fetchRemoteContent() async {
    try {
      final appContent = await _contentService.getContent();

      if (!mounted) return;

      if (appContent != null) {
        setState(() {
          // Dynamic Home Title
          if (appContent.home.title != null && appContent.home.title!.trim().isNotEmpty) {
            _title = appContent.home.title!;
          } else {
            _title = _defaultTitle;
          }

          // Dynamic Home Subtitle
          if (appContent.home.subtitle != null && appContent.home.subtitle!.trim().isNotEmpty) {
            _subtitle = appContent.home.subtitle!;
          } else {
            _subtitle = null;
          }

          // Dynamic Home Content
          if (appContent.home.content != null && appContent.home.content!.trim().isNotEmpty) {
            _content = appContent.home.content!;
          }

          // Dynamic Carousel Images
          if (appContent.dashboardImages.isNotEmpty) {
            _carouselImages = appContent.dashboardImages.map((e) => e.imageUrl).toList();
          } else {
            _carouselImages = [];
          }

          _isLoadingContent = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoadingContent = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingContent = false;
        });
      }
    }
  }

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

  Widget _buildCarousel() {
    final useNetwork = _carouselImages.isNotEmpty;

    return Padding(
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
            items: useNetwork
                ? _carouselImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final url = entry.value;
                    final fallbackAsset = _bundledCarouselImages[index % _bundledCarouselImages.length];

                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => Image.asset(
                        fallbackAsset,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList()
                : _bundledCarouselImages.map((path) {
                    return Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildReadingSection() {
    if (_content == null && _isLoadingContent) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: AppLoadingView(),
      );
    }

    if (_content == null) {
      return const AppEmptyView(
        title: "कोई सामग्री उपलब्ध नहीं है",
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
                Expanded(
                  child: Text(
                    _title,
                    style: const TextStyle(
                      fontFamily: 'TiroDevanagariHindi',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ],
            ),
            if (_subtitle != null && _subtitle!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  _subtitle!,
                  style: const TextStyle(
                    fontFamily: 'TiroDevanagariHindi',
                    fontSize: 13,
                    color: AppTheme.saffronAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(color: AppTheme.cardBorder, height: 1),
            const SizedBox(height: 14),
            Text(
              _content!,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("मन्दिरम्"),
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
      body: RefreshIndicator(
        onRefresh: _fetchRemoteContent,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            _buildCarousel(),
            const SizedBox(height: 16),
            _buildReadingSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
