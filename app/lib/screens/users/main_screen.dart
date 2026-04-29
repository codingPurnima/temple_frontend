import 'package:app/services/auth_service.dart';
import 'package:app/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

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
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (shouldLogout != true) return;
    try {
      await AuthService().logout();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', // make sure this route exists
        (route) => false,
      );
    } catch (e) {
      print("Logout error: $e");
    }
  }

  Future<String> loadText() async {
    return await rootBundle.loadString('assets/text/home_screen.txt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("भक्तिपथ"),
        actions: [
          IconButton(
            onPressed: () async {
              await _handleLogout(context);
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      drawer: const AppDrawer(),

      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Image.asset('assets/images/header_image.png'),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: FutureBuilder(
              future: loadText(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(snapshot.data!);
                } else {
                  return Text('No data');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
