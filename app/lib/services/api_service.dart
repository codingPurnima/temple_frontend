import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final AuthService _authService = AuthService();

  Future<http.Response> get(String url) async {
    final token = await _authService.getAccessToken();

    return http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
  }
}