import 'package:app/services/auth_service.dart';
import 'package:app/services/dashboard_service.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DashboardService _service = DashboardService();

  bool isLoading = true;
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    final result = await _service.getDashboard();

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  Future<void> _handleLogout(BuildContext context) async{
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

  @override
  Widget build(BuildContext context) {
    final events = data?["upcoming_events"] ?? [];
    final notifications = data?["notifications"] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
          onPressed: () async {
            await _handleLogout(context);
          },
          icon: Icon(Icons.logout),
        ),
        ]
      ),
      drawer: Drawer(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : data == null
            ? Center(child: Text("Failed to load data"))
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Image.asset(
                            'assets/images/drawer_image.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Welcome",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Upcoming Events",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  ...events.map<Widget>(
                    (event) => ListTile(
                      title: Text(event["title"]),
                      subtitle: Text(event["description"] ?? ""),
                    ),
                  ),

                  Divider(),

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Notifications",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  ...notifications.map<Widget>(
                    (notif) => ListTile(title: Text(notif["message"])),
                  ),
                ],
              ),
      ),

      body: RefreshIndicator(
        onRefresh: loadDashboard,
        child: ListView(
          children: [
            SizedBox(height: 20),
            Image.asset('assets/images/header_image.png'),
            SizedBox(height: 20),
            Center(child: Text("Welcome")),
          ],
        ),
      ),
    );
  }
}
