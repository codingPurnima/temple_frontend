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

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async{
    final result = await _service.getDashboard();

    if (result != null) {
      setState(() {
        notifications = result["notifications"] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("सूचनाएँ")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("No notifications"))
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
