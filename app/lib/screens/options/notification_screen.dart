import 'package:app/services/dashboard_service.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DashboardService _service = DashboardService();

  bool isLoading = true;
  List notifications = [];

  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false; // reset error before loading
      });

      final result = await _service.getDashboard();
      setState(() {
        notifications = result?["notifications"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load notifications. Try refreshing")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("सूचनाएँ")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? RefreshIndicator(
              onRefresh: () => loadNotifications(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [Center(child: Icon(Icons.error))],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];

                  return ListTile(
                    leading: const Icon(Icons.notifications),
                    title: Text(notif["message"] ?? ""),
                  );
                },
              ),
            ),
    );
  }
}
