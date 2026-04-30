import 'dart:convert';
import 'package:app/services/api_service.dart';
import '../core/constants.dart';

class CharacterService {
  final ApiClient _apiClient = ApiClient();

  Future<List> getCharacters({String? search}) async {
    String url = "$baseUrl/characters/get";

    if (search != null && search.isNotEmpty) {
      url += "?search=$search";
    }

    final response = await _apiClient.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error: ${response.statusCode}");
      print("Body: ${response.body}");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCharacterById(int id) async {
    final response =
        await _apiClient.get("$baseUrl/characters/by-id/$id");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      print("Error: ${response.statusCode}");
      print("Body: ${response.body}");
      return null;
    }
  }
}