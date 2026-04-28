import 'package:app/services/auth_service.dart';
import 'package:app/services/dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    if (result == null) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
      return;
    }  

    setState(() {
      data = result;
      isLoading = false;
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
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
    final events = data?["upcoming_events"] ?? [];
    final notifications = data?["notifications"] ?? [];
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
            )
          ],
        ),
      ),
    );
  }
}
