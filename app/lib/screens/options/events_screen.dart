import 'package:app/services/dashboard_service.dart';
import 'package:flutter/material.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final DashboardService _service = DashboardService();

  bool isLoading = true;
  List events = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      final result = await _service.getDashboard();
      setState(() {
          events = result?["upcoming_events"] ?? [];
          isLoading = false;
        });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("उत्सव ")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
          ? const Center(child: Text("No events found"))
          : RefreshIndicator(
              onRefresh: loadEvents,
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];

                  return Card(
                    child: ListTile(
                      title: Text(event["title"] ?? ""),
                      subtitle: Text(event["description"] ?? ""),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
