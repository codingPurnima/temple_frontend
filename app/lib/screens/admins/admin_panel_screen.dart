import 'package:app/core/app_theme.dart';
import 'package:app/screens/admins/create_events_screen.dart';
import 'package:app/screens/admins/dashboard_content.dart';
import 'package:app/screens/admins/manage_users_screen.dart';
import 'package:app/screens/common/login_screen.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/admin_card.dart';
import 'package:app/screens/admins/create_character_screen.dart';
import 'package:app/screens/admins/create_lyrics_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('प्रस्थान की पुष्टि / Confirm Logout'),
          content: const Text('क्या आप लॉगआउट करना चाहते हैं?'),
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
    try {
      await AuthService().logout();

      if (!mounted) return;

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final token = AuthService.accessToken ?? "";
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("प्रशासन / Admin Panel"),
        actions: [
          IconButton(
            tooltip: "Logout",
            onPressed: () async {
              await _handleLogout(context);
            },
            icon: const Icon(Icons.logout_rounded, size: 22),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(18),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.1,
        children: [
          const AdminCard(
            title: "Add Lyrics\n(पद जोड़ें)",
            icon: Icons.music_note_rounded,
            color: AppTheme.saffronAccent,
            screen: CreateLyricsScreen(),
          ),
          const AdminCard(
            title: "Add Character\n(चरित्र जोड़ें)",
            icon: Icons.person_add_alt_1_rounded,
            color: Color(0xFF2E7D32),
            screen: CreateCharacterScreen(),
          ),
          AdminCard(
            title: "Manage Users\n(उपयोगकर्ता)",
            icon: Icons.admin_panel_settings_rounded,
            color: const Color(0xFF0284C7),
            screen: ManageUsersScreen(token: token),
          ),
          const AdminCard(
            title: "Add Event\n(उत्सव जोड़ें)",
            icon: Icons.event_available_rounded,
            color: Color(0xFF4F46E5),
            screen: CreateEventsScreen(),
          ),
          const AdminCard( //DOESN'T WORK RN
            title: "View Participants\n(प्रतिभागी)",
            icon: Icons.people_alt_rounded,
            color: AppTheme.warmGold,
            screen: CreateCharacterScreen(),
          ),
          const AdminCard(
            title: "Manage App Content\n(सामग्री प्रबंधन)",
            icon: Icons.dashboard_customize_rounded,
            color: Color(0xFF7C3AED),
            screen: DashboardContent(),
          ),
          const AdminCard(
            title: "Sampradaya\n(संप्रदाय विवरण)",
            icon: Icons.menu_book_rounded,
            color: Color(0xFFC2410C),
            screen: CreateCharacterScreen(),
          ),
        ],
      ),
    );
  }
}