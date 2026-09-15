import 'package:app/core/app_theme.dart';
import 'package:app/widgets/section_title.dart';
import 'package:app/widgets/social_item.dart';
import 'package:flutter/material.dart';

class SocialMediaScreen extends StatelessWidget {
  const SocialMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("सोशल मीडिया"),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: const [
          SectionTitle(title: "YouTube"),
          SocialItem(
            title: "Bhaktipath",
            image: 'assets/images/BhaktipathYT.jpeg',
            url: "https://www.youtube.com/@BhaktiPath",
          ),

          SectionTitle(title: "Instagram"),
          SocialItem(
            title: "bhaktipath",
            image: "assets/images/BhaktipathInsta.jpeg",
            url: "https://instagram.com/bhaktipath",
          ),
          SocialItem(
            title: "bhaktipathmedia",
            image: "assets/images/BhaktipathMedia.jpeg",
            url: "https://instagram.com/bhaktipathmedia",
          ),

          SectionTitle(title: "Facebook"),
          SocialItem(
            title: "Shri Krishna Chandra Sastri Thakurji",
            image: "assets/images/KCSFB.jpeg",
            url: "https://facebook.com/Kcsthakurji",
          ),
          SocialItem(
            title: "Indresh Upadhyay",
            image: "assets/images/BhaktipathFB.jpeg",
            url: "https://facebook.com/indreshjiofficial",
          ),

          SectionTitle(title: "X (Twitter)"),
          SocialItem(
            title: "Indresh Upadhyay",
            image: "assets/images/BhaktipathYT.jpeg",
            url: "https://twitter.com/indreshji7",
          ),
        ],
      ),
    );
  }
}
