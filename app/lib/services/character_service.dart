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

  Future<bool> deleteCharacter(int id) async {
    final response = await _apiClient.delete("$baseUrl/characters/$id");
    return response.statusCode == 200;
  }

  Future<bool> updateCharacter(int id, Map<String, dynamic> body) async {
    final response = await _apiClient.patchRequest(
      "$baseUrl/characters/$id",
      body,
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return response.statusCode == 200;
  }
}