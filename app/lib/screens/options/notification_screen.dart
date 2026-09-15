import 'package:app/core/app_theme.dart';
import 'package:app/services/dashboard_service.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
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
        hasError = false;
      });

      final result = await _service.getDashboard();
      if (!mounted) return;
      setState(() {
        notifications = result?["notifications"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load notifications. Try refreshing"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(title: const Text("सूचनाएँ")),
      body: isLoading
          ? const AppLoadingView(message: "सूचनाएँ लोड हो रही हैं...")
          : hasError
          ? RefreshIndicator(
              onRefresh: () => loadNotifications(),
              child: AppErrorView(onRetry: () => loadNotifications()),
            )
          : notifications.isEmpty
          ? RefreshIndicator(
              onRefresh: () => loadNotifications(),
              child: const AppEmptyView(
                icon: Icons.notifications_none_rounded,
                title: "कोई नई सूचना नहीं है",
                subtitle: "नई सूचनाएँ आने पर यहाँ प्रदर्शित होंगी",
              ),
            )
          : RefreshIndicator(
              onRefresh: loadNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final message = notif["message"] ?? "";

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: AppTheme.cardBorder,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.saffronLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.warmGoldLight),
                            ),
                            child: const Icon(
                              Icons.notifications_active_outlined,
                              size: 20,
                              color: AppTheme.saffronAccent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message,
                                  style: const TextStyle(
                                    fontFamily: 'TiroDevanagariHindi',
                                    fontSize: 15,
                                    height: 1.5,
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
