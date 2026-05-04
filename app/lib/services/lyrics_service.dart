import 'dart:convert';
import 'package:app/services/api_service.dart';
import '../core/constants.dart';

class LyricsService {
  final ApiClient _apiClient = ApiClient();

  Future<List> getLyrics({String? search}) async {
    String url = "$baseUrl/lyrics/get";

    if (search != null && search.isNotEmpty) {
      url += "?search=$search";
    }

    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getLyricById(int id) async {
    final response = await _apiClient.get("$baseUrl/lyrics/by-id/$id");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      return null;
    }
  }

  Future<bool> deleteLyric(int id) async {
    final response = await _apiClient.delete("$baseUrl/lyrics/$id");
    return response.statusCode == 200;
  }

  Future<bool> updateLyric(int id, Map<String, dynamic> body) async {
    final response = await _apiClient.patchRequest(
      "$baseUrl/lyrics/$id",
      body,
    );

    return response.statusCode == 200;
  }
}
