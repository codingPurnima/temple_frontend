import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class QuoteScreen extends StatelessWidget {
  QuoteScreen({super.key});

  final ScreenshotController screenshotController = ScreenshotController();
  final String quote =
      "हरि मिले तो वैकुंठ दिलावे। \nहरिजन मिले तो हरि सौं मिलावे।।";

  final String org = "भक्तिपथ";

  Future<void> shareQuote() async {
    final image = await screenshotController.capture();
    if (image == null) return;
    final directory = await getTemporaryDirectory();
    final imagePath = File('${directory.path}/quote.png');
    await imagePath.writeAsBytes(image);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(imagePath.path)],
      text: "नित्य सुविचार",
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("सुविचार")),
      body: Screenshot(
        controller: screenshotController,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Blurred background image
              Positioned.fill(
                child: ClipRect(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: 2,
                      sigmaY: 2,
                    ),
                    child: Image.asset(
                      "assets/images/quote.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Dark overlay
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.18))),
              // Quote text
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 40,
                ),
                child: Center(
                  child: Text(
                    quote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 37,
                      height: 1.7,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFE0B2),
                    ),
                  ),
                ),
              ),
          
              // Logo
              Positioned(
                top: 20,
                left: 20,
                child: CircleAvatar(
                  maxRadius: 18,
                  backgroundImage: AssetImage(
                    "assets/images/BhaktipathYT.jpeg",
                  ),
                ),
              ),
          
              // Watermark
              Positioned(
                bottom: 30,
                left: 20,
                child: Opacity(
                  opacity: 0.18,
                  child: Text(
                    org,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 52, 42, 42),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
          
              // Share button
              Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: shareQuote,
                  child: const Icon(
                    Icons.share_rounded,
                    color: Colors.white,
                    size: 32,
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