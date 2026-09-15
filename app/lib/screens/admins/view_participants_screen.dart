import 'package:app/core/app_theme.dart';
import 'package:app/services/participant_service.dart';
import 'package:app/widgets/participant_model.dart';
import 'package:app/widgets/state_widgets/app_empty.dart';
import 'package:app/widgets/state_widgets/app_error.dart';
import 'package:app/widgets/state_widgets/app_loading.dart';
import 'package:flutter/material.dart';

class ViewParticipantsScreen extends StatefulWidget {
  final int eventId;
  final String token;
  const ViewParticipantsScreen({
    super.key,
    required this.eventId,
    required this.token,
  });

  @override
  State<ViewParticipantsScreen> createState() => _ViewParticipantsScreenState();
}

class _ViewParticipantsScreenState extends State<ViewParticipantsScreen> {
  late Future<List<Participant>> participantsFuture;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  void _loadParticipants() {
    participantsFuture = ParticipantService.getParticipants(
      widget.eventId,
      widget.token,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadParticipants();
    });
    await participantsFuture;
  }

  Widget _buildStatusChip(String status) {
    final isConfirmed = status.toUpperCase().contains("CONFIRM") ||
        status.toUpperCase().contains("REGISTER") ||
        status.toUpperCase() == "ATTENDING";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isConfirmed
            ? AppTheme.successGreen.withValues(alpha: 0.12)
            : AppTheme.saffronAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConfirmed
              ? AppTheme.successGreen.withValues(alpha: 0.4)
              : AppTheme.saffronAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isConfirmed ? AppTheme.successGreen : AppTheme.saffronAccent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.parchmentBackground,
      appBar: AppBar(
        title: const Text("प्रतिभागी सूची / Participants"),
      ),
      body: FutureBuilder<List<Participant>>(
        future: participantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView(message: "प्रतिभागी लोड हो रहे हैं...");
          }
          if (snapshot.hasError) {
            return AppErrorView(
              message: "प्रतिभागी डेटा लोड करने में त्रुटि हुई",
              onRetry: () => setState(_loadParticipants),
            );
          }

          final participants = snapshot.data ?? [];
          if (participants.isEmpty) {
            return AppEmptyView(
              title: "कोई प्रतिभागी पंजीकृत नहीं",
              subtitle: "इस आयोजन के लिए अभी तक किसी भक्त ने पंजीकरण नहीं कराया है",
              onRefresh: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppTheme.saffronAccent,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final p = participants[index];

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.08),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppTheme.primaryNavy,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "भक्त / User #${p.userId}",
                                  style: const TextStyle(
                                    fontFamily: 'TiroDevanagariHindi',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "पंजीकरण ID: #${p.id}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(p.status),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
