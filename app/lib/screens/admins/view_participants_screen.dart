import 'package:app/services/participant_service.dart';
import 'package:app/widgets/participant_model.dart';
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

    participantsFuture = ParticipantService.getParticipants(
      widget.eventId,
      widget.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(fit: BoxFit.scaleDown, child: Text("Participants")),
      ),
      body: FutureBuilder<List<Participant>>(
        future: participantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final participants = snapshot.data ?? [];
          if (participants.isEmpty) {
            return const Center(
              child: Text("No participants found"),
            );
          }
          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final p = participants[index];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(p.userId.toString()),
                  ),
                  title: Text("User ID: ${p.userId}"),
                  subtitle: Text("Status: ${p.status}"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
