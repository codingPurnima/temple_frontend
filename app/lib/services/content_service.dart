import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/content_model.dart';
import 'api_service.dart';

class ContentService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches the current app content (home texts, carousel images, and quote).
  Future<AppContent?> getContent() async {
    try {
      final response = await _apiClient.get("$baseUrl/content");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AppContent.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Updates home text and/or quote content.
  /// Sends ONLY fields and files that are explicitly provided.
  Future<AppContent?> updateContent({
    String? homeTitle,
    String? homeSubtitle,
    String? homeContent,
    String? quoteText,
    File? quoteImage,
    bool clearQuoteImage = false,
  }) async {
    try {
      final fields = <String, String>{};
      final files = <http.MultipartFile>[];

      if (homeTitle != null) fields['home_title'] = homeTitle;
      if (homeSubtitle != null) fields['home_subtitle'] = homeSubtitle;
      if (homeContent != null) fields['home_content'] = homeContent;
      if (quoteText != null) fields['quote'] = quoteText;

      // Only send clear_quote_image when explicitly requested as true
      if (clearQuoteImage) {
        fields['clear_quote_image'] = 'true';
      }

      if (quoteImage != null) {
        files.add(await http.MultipartFile.fromPath(
          'quote_image',
          quoteImage.path,
        ));
      }

      if (fields.isEmpty && files.isEmpty) {
        return null;
      }

      final response = await _apiClient.multipartRequest(
        method: 'PUT',
        url: "$baseUrl/admin-content/content",
        fields: fields.isNotEmpty ? fields : null,
        files: files.isNotEmpty ? files : null,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AppContent.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Uploads one or more dashboard/carousel images.
  /// Uses FastAPI multipart field name 'dashboard_images' for each file.
  Future<List<DashboardImage>?> uploadDashboardImages(List<File> images) async {
    if (images.isEmpty) return [];

    try {
      final files = <http.MultipartFile>[];

      for (final image in images) {
        files.add(await http.MultipartFile.fromPath(
          'dashboard_images',
          image.path,
        ));
      }

      final response = await _apiClient.multipartRequest(
        method: 'POST',
        url: "$baseUrl/admin-content/content/dashboard-images",
        files: files,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((item) => DashboardImage.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Deletes a single dashboard/carousel image by its ID.
  Future<bool> deleteDashboardImage(int imageId) async {
    try {
      final response = await _apiClient.delete(
        "$baseUrl/admin-content/content/dashboard-images/$imageId",
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
