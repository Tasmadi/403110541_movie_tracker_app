import '../models/movie.dart';
import '../services/api_service.dart';

class MediaRepository {
  ApiService apiService;

  List<Movie>? popularMoviesCache;

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

  void clearCache() {
    popularMoviesCache = null;
  }
}
