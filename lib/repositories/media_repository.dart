import '../models/movie.dart';
import '../models/search_result_item.dart';
import '../services/api_service.dart';
import '../models/movie_detail.dart';
import '../models/season_detail.dart';
import '../models/series_detail.dart';

class MediaRepository {
  ApiService apiService;

  List<Movie>? popularMoviesCache;

  Map<String, List<SearchResultItem>> searchCache = {};

  Map<int, MovieDetail> movieDetailCache = {};

  Map<int, SeriesDetail> seriesDetailCache = {};

  Map<String, SeasonDetail> seasonDetailCache = {};

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

  Future<MovieDetail> getMovieDetail(
    int movieId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && movieDetailCache.containsKey(movieId)) {
      return movieDetailCache[movieId]!;
    }

    List<Map<String, dynamic>> responses =
        await Future.wait<Map<String, dynamic>>([
      apiService.get(
        '/movie/$movieId',
      ),
      apiService.get(
        '/movie/$movieId/credits',
      ),
    ]);

    Map<String, dynamic> detailResponse = responses[0];

    Map<String, dynamic> creditsResponse = responses[1];

    MovieDetail movieDetail = MovieDetail.fromJson(
      detailResponse,
      creditsResponse,
    );

    movieDetailCache[movieId] = movieDetail;

    return movieDetail;
  }

  Future<SeriesDetail> getSeriesDetail(
    int seriesId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && seriesDetailCache.containsKey(seriesId)) {
      return seriesDetailCache[seriesId]!;
    }

    List<Map<String, dynamic>> responses =
        await Future.wait<Map<String, dynamic>>([
      apiService.get(
        '/tv/$seriesId',
      ),
      apiService.get(
        '/tv/$seriesId/aggregate_credits',
      ),
    ]);

    SeriesDetail seriesDetail = SeriesDetail.fromJson(
      responses[0],
      responses[1],
    );

    seriesDetailCache[seriesId] = seriesDetail;

    return seriesDetail;
  }

  Future<SeasonDetail> getSeasonDetail(
    int seriesId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    String cacheKey = '${seriesId}_$seasonNumber';

    if (!forceRefresh && seasonDetailCache.containsKey(cacheKey)) {
      return seasonDetailCache[cacheKey]!;
    }

    Map<String, dynamic> response = await apiService.get(
      '/tv/$seriesId/season/$seasonNumber',
    );

    SeasonDetail season = SeasonDetail.fromJson(response);

    seasonDetailCache[cacheKey] = season;

    return season;
  }

  void clearCache() {
    popularMoviesCache = null;
    searchCache.clear();
    movieDetailCache.clear();
    seriesDetailCache.clear();
    seasonDetailCache.clear();
  }
}
