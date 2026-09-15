import 'package:app/core/app_theme.dart';
import 'package:app/helper/session.dart';
import 'package:app/screens/admins/admin_panel_screen.dart';
import 'package:app/screens/options/bhakt_charitra_screen.dart';
import 'package:app/screens/options/events_screen.dart';
import 'package:app/screens/options/notification_screen.dart';
import 'package:app/screens/options/padavali_screen.dart';
import 'package:app/screens/options/profile_screen.dart';
import 'package:app/screens/options/quote_screen.dart';
import 'package:app/screens/options/social_media_screen.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // closes drawer first
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isAdmin = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isAdmin ? AppTheme.saffronLight : Colors.transparent,
        leading: Icon(
          icon,
          color: isAdmin ? AppTheme.saffronAccent : AppTheme.primaryNavy,
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'TiroDevanagariHindi',
            fontSize: 16,
            fontWeight: isAdmin ? FontWeight.bold : FontWeight.w600,
            color: isAdmin ? AppTheme.saffronAccent : AppTheme.textPrimary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 18,
          color: AppTheme.textMuted,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 270,
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 160,
            decoration: const BoxDecoration(
              color: AppTheme.primaryNavy,
              border: Border(
                bottom: BorderSide(color: AppTheme.warmGold, width: 3),
              ),
            ),
            child: Image.asset(
              'assets/images/DrawerHeader.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            context: context,
            icon: Icons.music_note_rounded,
            title: "पदावली",
            onTap: () => _navigate(context, const PadavaliScreen()),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.auto_stories_rounded,
            title: "भक्त चरित्र",
            onTap: () => _navigate(context, const BhaktCharitraScreen()),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.notifications_none_rounded,
            title: "सूचनाएँ",
            onTap: () => _navigate(context, const NotificationScreen()),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.celebration_outlined,
            title: "उत्सव",
            onTap: () => _navigate(context, const EventsScreen()),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.tag_rounded,
            title: "सोशल मीडिया",
            onTap: () => _navigate(context, const SocialMediaScreen()),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.format_quote_rounded,
            title: "सुविचार",
            onTap: () => _navigate(context, QuoteScreen()),
          ),
          _buildDrawerItem(
            context: context,
            icon: Icons.person_outline_rounded,
            title: "प्रोफ़ाइल",
            onTap: () => _navigate(context, const ProfileScreen()),
          ),
          if (Session.isAdmin) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(color: AppTheme.cardBorder, height: 1),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.admin_panel_settings_rounded,
              title: "Admin Panel",
              isAdmin: true,
              onTap: () => _navigate(context, const AdminPanelScreen()),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
