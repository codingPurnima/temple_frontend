import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/core/constants.dart';
import 'package:app/widgets/participant_model.dart';

class ParticipantService {
  static Future<List<Participant>> getParticipants(
    int eventId,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId/participants'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Participant.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load participants');
    }
  }
}