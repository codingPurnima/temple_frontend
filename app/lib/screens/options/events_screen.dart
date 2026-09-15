import 'package:app/core/app_theme.dart';
import 'package:app/helper/date_utils.dart';
import 'package:app/services/dashboard_service.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
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
        hasError = false;
      });

      final result = await _service.getDashboard();
      if (!mounted) return;
      setState(() {
        events = result?["upcoming_events"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load data. Try refreshing.")),
      );
    }
  }

  void _showEventSheet(Map event) {
    final isRegistered = event["is_registered"] == true;
    final status = event["registration_status"]?.toString().toLowerCase();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Title
                Text(
                  event["title"] ?? "",
                  style: const TextStyle(
                    fontFamily: 'TiroDevanagariHindi',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                // Date badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.saffronLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.warmGoldLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: AppTheme.saffronAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${DateUtilsCustom.formatToDDMMYYYY(event["start_date"])} → ${DateUtilsCustom.formatToDDMMYYYY(event["end_date"])}",
                        style: const TextStyle(
                          fontFamily: 'TiroDevanagariHindi',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.saffronAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                if (event["capacity"] != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "कुल स्थान (Capacity): ${event["capacity"]}",
                        style: const TextStyle(
                          fontFamily: 'TiroDevanagariHindi',
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Description
                Text(
                  event["description"] ?? "विवरण उपलब्ध नहीं है",
                  style: const TextStyle(
                    fontFamily: 'TiroDevanagariHindi',
                    fontSize: 15,
                    height: 1.6,
                    color: AppTheme.textPrimary,
                  ),
                ),

                if (isRegistered && status != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: status == "confirmed"
                          ? AppTheme.successLight
                          : AppTheme.saffronLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: status == "confirmed"
                            ? AppTheme.successGreen.withValues(alpha: 0.3)
                            : AppTheme.warmGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          status == "confirmed"
                              ? Icons.check_circle_rounded
                              : Icons.access_time_rounded,
                          color: status == "confirmed"
                              ? AppTheme.successGreen
                              : AppTheme.saffronAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status == "confirmed"
                              ? "आपका पंजीकरण स्वीकृत है (Confirmed) 🎉"
                              : "प्रतीक्षारत सूची में है (Waitlist) ⏳",
                          style: TextStyle(
                            fontFamily: 'TiroDevanagariHindi',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: status == "confirmed"
                                ? AppTheme.successGreen
                                : AppTheme.saffronAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: isRegistered
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _leaveEvent(event["id"]),
                          child: const Text(
                            "पंजीकरण रद्द करें / Leave Event",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _registerEvent(event["id"]),
                          child: const Text(
                            "पंजीकरण करें / Register",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
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
    ).showSnackBar(const SnackBar(content: Text("पंजीकरण हो रहा है...")));

    try {
      final response = await _service.joinEvent(eventId);

      final status = response["status"].toString().toLowerCase();

      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to register")));
    }
  }

  Future<void> _leaveEvent(int eventId) async {
    Navigator.pop(context);

    try {
      await _service.leaveEvent(eventId);

      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to leave event")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(title: const Text("उत्सव एवं कार्यक्रम")),
      body: isLoading
          ? const AppLoadingView(message: "उत्सव लोड हो रहे हैं...")
          : hasError
          ? RefreshIndicator(
              onRefresh: () => loadEvents(),
              child: AppErrorView(onRetry: () => loadEvents()),
            )
          : events.isEmpty
          ? RefreshIndicator(
              onRefresh: () => loadEvents(),
              child: const AppEmptyView(
                icon: Icons.celebration_outlined,
                title: "कोई आगामी उत्सव उपलब्ध नहीं है",
                subtitle: "कृपया कुछ समय बाद पुनः देखें",
              ),
            )
          : RefreshIndicator(
              onRefresh: loadEvents,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isRegistered = event["is_registered"] == true;
                  final status = event["registration_status"]
                      ?.toString()
                      .toLowerCase();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: AppTheme.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showEventSheet(event),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    event["title"] ?? "",
                                    style: const TextStyle(
                                      fontFamily: 'TiroDevanagariHindi',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isRegistered)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: status == "confirmed"
                                          ? AppTheme.successLight
                                          : AppTheme.saffronLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: status == "confirmed"
                                            ? AppTheme.successGreen
                                            : AppTheme.saffronAccent,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      status == "confirmed"
                                          ? "पंजीकृत"
                                          : "प्रतीक्षारत",
                                      style: TextStyle(
                                        fontFamily: 'TiroDevanagariHindi',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: status == "confirmed"
                                            ? AppTheme.successGreen
                                            : AppTheme.saffronAccent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event["description"] ?? "",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'TiroDevanagariHindi',
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(
                              color: AppTheme.cardBorder,
                              height: 1,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 14,
                                      color: AppTheme.saffronAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${DateUtilsCustom.formatToDDMMYYYY(event["start_date"])} - ${DateUtilsCustom.formatToDDMMYYYY(event["end_date"])}",
                                      style: const TextStyle(
                                        fontFamily: 'TiroDevanagariHindi',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      "विवरण देखें",
                                      style: TextStyle(
                                        fontFamily: 'TiroDevanagariHindi',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.saffronAccent,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: AppTheme.saffronAccent,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
