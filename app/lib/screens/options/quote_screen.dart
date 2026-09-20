import 'dart:io';
import 'dart:ui';
import 'package:app/core/app_theme.dart';
import 'package:app/services/content_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  static const String _defaultQuote =
      "हरि मिले तो वैकुंठ दिलावे।\nहरिजन मिले तो हरि सौं मिलावे।।";
  static const String _bundledImage = "assets/images/quote.jpg";
  static const String _org = "मन्दिरम्";

  final ScreenshotController screenshotController = ScreenshotController();
  final ContentService _contentService = ContentService();

  // Initialized to defaults — screen is usable immediately before API responds
  String? _quoteText;
  String? _quoteImageUrl;
  bool _isLoadingContent = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final content = await _contentService.getContent();

      if (!mounted) return;

      if (content != null) {
        setState(() {
          // Quote text: backend value or default after API response
          if (content.quote.text != null &&
              content.quote.text!.trim().isNotEmpty) {
            _quoteText = content.quote.text!;
          } else {
            _quoteText = _defaultQuote;
          }

          // Quote image: backend URL or bundled fallback after API response
          if (content.quote.imageUrl != null &&
              content.quote.imageUrl!.trim().isNotEmpty) {
            _quoteImageUrl = content.quote.imageUrl;
          } else {
            _quoteImageUrl = null;
          }

          _isLoadingContent = false;
        });
      } else {
        setState(() {
          _quoteText = _defaultQuote;
          _quoteImageUrl = null;
          _isLoadingContent = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _quoteText = _defaultQuote;
          _quoteImageUrl = null;
          _isLoadingContent = false;
        });
      }
    }
  }

  Future<void> shareQuote() async {
    final image = await screenshotController.capture();
    if (image == null) return;
    final directory = await getTemporaryDirectory();
    final imagePath = File('${directory.path}/quote.png');
    await imagePath.writeAsBytes(image);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(imagePath.path)],
        text: "नित्य सुविचार - भक्तिपथ",
      ),
    );
  }

  Widget _buildBackground() {
    if (_isLoadingContent) {
      return Container(
        color: AppTheme.primaryNavy,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.warmGold,
          ),
        ),
      );
    }

    if (_quoteImageUrl != null) {
      return Image.network(
        _quoteImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Image.asset(
          _bundledImage,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      _bundledImage,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      appBar: AppBar(
        title: const Text("नित्य सुविचार"),
        actions: [
          IconButton(
            tooltip: "Share Quote",
            icon: const Icon(Icons.share_rounded, size: 22),
            onPressed: shareQuote,
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Background Image with gentle blur
              Positioned.fill(
                child: ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: _buildBackground(),
                  ),
                ),
              ),

              // Elegant Dark Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Logo Badge
              Positioned(
                top: 24,
                left: 24,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.warmGold,
                          width: 1.5,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage(
                          "assets/images/Splash.png",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "मन्दिरम्",
                      style: TextStyle(
                        fontFamily: 'TiroDevanagariHindi',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Centered Sacred Quote Card
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 36,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.warmGold.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          color: AppTheme.warmGoldLight,
                          size: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _quoteText??'',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'TiroDevanagariHindi',
                            fontSize: 28,
                            height: 1.8,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFF3E0),
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Watermark at bottom left
              Positioned(
                bottom: 24,
                left: 24,
                child: Opacity(
                  opacity: 0.4,
                  child: Text(
                    _org,
                    style: const TextStyle(
                      fontFamily: 'TiroDevanagariHindi',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // Bottom Right Share Pill
              Positioned(
                bottom: 20,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: shareQuote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.saffronAccent,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "साझा करें",
                            style: TextStyle(
                              fontFamily: 'TiroDevanagariHindi',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
