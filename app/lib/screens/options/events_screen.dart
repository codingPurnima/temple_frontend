import 'package:app/helper/date_utils.dart';
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

  void _showEventSheet(Map event) {
    final isRegistered = event["is_registered"] == true;
    // final status = event["registration_status"];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // allows full height
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                /// title
                Text(
                  event["title"] ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// description
                Text(
                  event["description"] ?? "No description",
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 16),

                /// dates
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${DateUtilsCustom.formatToDDMMYYYY(event["start_date"])} → ${DateUtilsCustom.formatToDDMMYYYY(event["end_date"])}",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// capacity
                if (event["capacity"] != null)
                  Text("Capacity: ${event["capacity"]}"),

                const SizedBox(height: 24),

                /// register button
                SizedBox(
                  width: double.infinity,
                  child: isRegistered
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () => _leaveEvent(event["id"]),
                          child: const Text("Leave Event"),
                        )
                      : ElevatedButton(
                          onPressed: () => _registerEvent(event["id"]),
                          child: const Text("Register"),
                        ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _registerEvent(int eventId) async {
    Navigator.pop(context);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Registering...")));

    try {
      final response = await _service.joinEvent(eventId);

      final status = response["status"].toString().toLowerCase();

      setState(() {
        final index = events.indexWhere((e) => e["id"] == eventId);
        if (index != -1) {
          events[index]["is_registered"] = true;
          events[index]["registration_status"] = status;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == "confirmed"
                ? "You're confirmed 🎉"
                : "Added to waitlist ⏳",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to register")));
    }
  }

  Future<void> _leaveEvent(int eventId) async {
    Navigator.pop(context);

    try {
      await _service.leaveEvent(eventId);

      setState(() {
        final index = events.indexWhere((e) => e["id"] == eventId);
        if (index != -1) {
          events[index]["is_registered"] = false;
          events[index]["registration_status"] = null;
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("You left the event")));

      loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to leave event")));
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
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showEventSheet(event),
                    ),
                  );
                },
              ),
            ),
    );
  }
}