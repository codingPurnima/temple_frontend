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
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(image), // or NetworkImage
      ),
      title: Text(title),
      onTap: () async {
        final Uri uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      },
    );
  }
}