import 'package:app/screens/options/bhakt_charitra_screen.dart';
import 'package:app/screens/options/karyakram_screen.dart';
import 'package:app/screens/options/padavali_screen.dart';
import 'package:app/screens/options/panchang_screen.dart';
import 'package:app/screens/options/profile_screen.dart';
import 'package:app/screens/options/social_media_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/users/events_screen.dart';
import 'package:app/screens/users/notification_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // closes drawer first
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 225,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(color: Colors.white),
              child: Image.asset(
                'assets/images/DrawerHeader.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: const Text("पदावली "),
            onTap: () {
              _navigate(context, const PadavaliScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_3),
            title: const Text("भक्त चरित्र "),
            onTap: () {
              _navigate(context, const BhaktCharitraScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("सूचनाएँ "),
            onTap: () {
              _navigate(context, const NotificationScreen());
            },
          ),
          ListTile( // these are the ones for which people can register 
            leading: const Icon(Icons.event),
            title: const Text("उत्सव कार्यक्रम "),
            onTap: () {
              _navigate(context, const EventsScreen());
            },
          ),
          ListTile( // vaishnav specific dates
            leading: const Icon(Icons.calendar_month),
            title: const Text("पञ्चाङ्ग "),
            onTap: () {
              _navigate(context, const PanchangScreen());
            },
          ),
          ListTile( 
            leading: const Icon(Icons.calendar_today),
            title: const Text("कथा कार्यक्रम "),
            onTap: () {
              _navigate(context, const KaryakramScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("सोशल मीडिया"),
            onTap: () {
              _navigate(context, const SocialMediaScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("प्रोफ़ाइल"),
            onTap: () {
              _navigate(context, const ProfileScreen());
            },
          ),
        ],
      ),
    );
  }
}
