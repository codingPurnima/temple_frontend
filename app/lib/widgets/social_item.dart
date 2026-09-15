import 'package:app/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialItem extends StatelessWidget {
  final String title;
  final String image;
  final String url;

  const SocialItem({
    super.key,
    required this.title,
    required this.image,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.parchmentBackground,
          backgroundImage: AssetImage(image),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'TiroDevanagariHindi',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.open_in_new_rounded,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        onTap: () async {
          final Uri uri = Uri.parse(url);
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        },
      ),
    );
  }
}