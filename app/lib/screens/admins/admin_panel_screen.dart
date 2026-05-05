import 'package:app/screens/admins/create_events_screen.dart';
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
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // cancel
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // confirm
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 6, 24, 39),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    if (shouldLogout != true) return;
    try {
      await AuthService().logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Logout error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final token = AuthService.accessToken!;
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(fit: BoxFit.scaleDown, child: Text("भक्तिपथ- Admin")),
        actions: [
          IconButton(
            onPressed: () async {
              await _handleLogout(context);
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            AdminCard(
              title: "Add Lyrics",
              icon: Icons.music_note,
              color: Colors.deepPurple,
              screen: CreateLyricsScreen(),
            ),
            AdminCard(
              title: "Add Character",
              icon: Icons.person,
              color: Colors.teal,
              screen: CreateCharacterScreen(),
            ),
            AdminCard(
              title: "Make Admin",
              icon: Icons.add_moderator_outlined,
              color: Colors.cyan,
              screen: ManageUsersScreen(token: token,),
            ),
            AdminCard(
              title: "Add Event",
              icon: Icons.event_available,
              color: Color(0xFF1E3A8A),
              screen: CreateEventsScreen(),
            ),
            AdminCard(
              title: "View Participants",
              icon: Icons.people_rounded,
              color: Color(0xFFF59E0B),
              screen: CreateCharacterScreen(),
            ),
            AdminCard(
              title: "Add quote",
              icon: Icons.join_full,
              color: Color.fromARGB(255, 65, 163, 195),
              screen: CreateCharacterScreen(),
            ),
            AdminCard(
              title: "Add sampradaya information",
              icon: Icons.list_alt,
              color: Color.fromARGB(255, 65, 163, 195),
              screen: CreateCharacterScreen(),
            ),
          ],
        ),
      ),
    );
  }
}