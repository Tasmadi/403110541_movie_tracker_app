import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/imdb_info.dart';
import '../utils/api_config.dart';

class OmdbService {
  final http.Client client;

  final Map<String, ImdbInfo?> _cache = {};

  OmdbService({
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<ImdbInfo?> getByImdbId(
    String imdbId, {
    bool forceRefresh = false,
  }) async {
    String normalizedId = imdbId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    if (ApiConfig.omdbApiKey.isEmpty) {
      return null;
    }

    if (!forceRefresh &&
        _cache.containsKey(
          normalizedId,
        )) {
      return _cache[normalizedId];
    }

    Uri uri = Uri.https(
      'www.omdbapi.com',
      '/',
      {
        'apikey': ApiConfig.omdbApiKey,
        'i': normalizedId,
        'r': 'json',
      },
    );

    try {
      http.Response response = await client.get(uri).timeout(
            const Duration(
              seconds: 15,
            ),
          );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      dynamic decoded = jsonDecode(
        response.body,
      );

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      if (decoded['Response']?.toString().toLowerCase() == 'false') {
        _cache[normalizedId] = null;

        return null;
      }

      ImdbInfo info = ImdbInfo.fromJson(
        decoded,
      );

      _cache[normalizedId] = info;

      return info;
    } catch (_) {
      // IMDb is supplemental information.
      // Failure must not break the detail screen.
      return null;
    }
  }

  void clearCache() {
    _cache.clear();
  }
}
