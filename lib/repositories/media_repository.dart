import '../models/movie.dart';
import '../models/search_result_item.dart';
import '../services/api_service.dart';

class MediaRepository {
  ApiService apiService;

  List<Movie>? popularMoviesCache;

  Map<String, List<SearchResultItem>> searchCache = {};

  MediaRepository({
    required this.apiService,
  });

  Future<List<Movie>> getPopularMovies({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && popularMoviesCache != null) {
      return popularMoviesCache!;
    }

    Map<String, dynamic> response = await apiService.get(
      '/movie/popular',
      queryParameters: {
        'page': '1',
      },
    );

    List<dynamic> results = response['results'] ?? [];

    List<Movie> movies = results.map((item) {
      return Movie.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();

    popularMoviesCache = movies;

    return movies;
  }

  Future<List<SearchResultItem>> searchMedia(
    String query, {
    bool forceRefresh = false,
  }) async {
    String normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return [];
    }

    String cacheKey = normalizedQuery.toLowerCase();

    if (!forceRefresh && searchCache.containsKey(cacheKey)) {
      return searchCache[cacheKey]!;
    }

    Map<String, dynamic> response = await apiService.get(
      '/search/multi',
      queryParameters: {
        'query': normalizedQuery,
        'page': '1',
        'include_adult': 'false',
      },
    );

    List<dynamic> results = response['results'] ?? [];

    List<SearchResultItem> items = results.where((item) {
      if (item is! Map<String, dynamic>) {
        return false;
      }

      String mediaType = item['media_type'] ?? '';

      return mediaType == 'movie' || mediaType == 'tv';
    }).map((item) {
      return SearchResultItem.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();

    searchCache[cacheKey] = items;

    return items;
  }

  void clearCache() {
    popularMoviesCache = null;
    searchCache.clear();
  }
}
