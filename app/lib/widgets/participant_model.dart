class Participant {
  final int id;
  final int userId;
  final int eventId;
  final String status;

  Participant({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.status,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      status: json['status'],
    );
  }
}