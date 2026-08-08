import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';

class ApiService {
  http.Client client;

  ApiService({
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    if (ApiConfig.tmdbToken.isEmpty) {
      throw Exception(
        'TMDB Token is not configured.',
      );
    }

    Map<String, String> parameters = {
      'language': 'en-US',
    };

    if (queryParameters != null) {
      parameters.addAll(queryParameters);
    }

    Uri uri = Uri.https(
      ApiConfig.baseHost,
      '/3$path',
      parameters,
    );

    try {
      http.Response response = await client.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${ApiConfig.tmdbToken}',
          'accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic decodedData = jsonDecode(
          response.body,
        );

        if (decodedData is Map<String, dynamic>) {
          return decodedData;
        }

        throw Exception(
          'Invalid response format.',
        );
      }

      if (response.statusCode == 401) {
        throw Exception(
          'TMDB authentication failed.',
        );
      }

      if (response.statusCode == 404) {
        throw Exception(
          'Requested information was not found.',
        );
      }

      throw Exception(
        'TMDB request failed with status '
        '${response.statusCode}.',
      );
    } on SocketException {
      throw Exception(
        'Internet connection is not available.',
      );
    } on TimeoutException {
      throw Exception(
        'Request timed out.',
      );
    } on FormatException {
      throw Exception(
        'Invalid data received from TMDB.',
      );
    }
  }
}
