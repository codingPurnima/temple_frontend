import 'package:app/helper/session.dart';
import 'package:app/screens/admins/admin_panel_screen.dart';
import 'package:app/screens/options/bhakt_charitra_screen.dart';
import 'package:app/screens/options/karyakram_screen.dart';
import 'package:app/screens/options/padavali_screen.dart';
import 'package:app/screens/options/panchang_screen.dart';
import 'package:app/screens/options/profile_screen.dart';
import 'package:app/screens/options/quote_screen.dart';
import 'package:app/screens/options/sampradaya_screen.dart';
import 'package:app/screens/options/social_media_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/options/events_screen.dart';
import 'package:app/screens/options/notification_screen.dart';

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
            title: const Text("पदावली", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const PadavaliScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_3),
            title: const Text("भक्त चरित्र", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const BhaktCharitraScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("सूचनाएँ", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const NotificationScreen());
            },
          ),
          ListTile( // these are the ones for which people can register 
            leading: const Icon(Icons.event),
            title: const Text("उत्सव", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const EventsScreen());
            },
          ),
          ListTile( // vaishnav specific dates
            leading: const Icon(Icons.calendar_month),
            title: const Text("पञ्चाङ्ग", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const PanchangScreen());
            },
          ),
          ListTile( 
            leading: const Icon(Icons.calendar_today),
            title: const Text("कथा कार्यक्रम", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const KaryakramScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("सोशल मीडिया", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const SocialMediaScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text("सुविचार", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const QuoteScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("प्रोफ़ाइल", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const ProfileScreen());
            },
          ),
          if(Session.isPremiumUser || Session.isAdmin)
            ListTile(
              leading: const Icon(Icons.book_outlined),
              title: const Text("प्रकाशण", style: TextStyle(color: Colors.black),),
              onTap: () {
                _navigate(context, const SampradayaScreen()); //temporarily navigating here
              },
            ),
          if(Session.isPremiumUser || Session.isAdmin)
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("संप्रदाय विशेष", style: TextStyle(color: Colors.black),),
              onTap: () {
                _navigate(context, const SampradayaScreen());
              },
            ),
          if(Session.isAdmin)
            ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text("Admin Panel", style: TextStyle(color: Colors.black),),
            onTap: () {
              _navigate(context, const AdminPanelScreen());
            },
          ),
        ],
      ),
    );
  }
}
