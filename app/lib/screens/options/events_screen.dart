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
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false; // reset error before loading
      });

      final result = await _service.getDashboard();
      setState(() {
        events = result?["upcoming_events"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data. Try refreshing.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("उत्सव ")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
          ? RefreshIndicator(
              onRefresh: () => loadEvents(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [Center(child: Icon(Icons.error))],
              ),
            )
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
