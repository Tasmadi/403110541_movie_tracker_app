import '../models/movie.dart';
import '../models/search_result_item.dart';
import '../services/api_service.dart';
import '../models/movie_detail.dart';
import '../models/user_media_item.dart';
import '../models/search_page_result.dart';
import '../models/search_type.dart';
import '../models/season_detail.dart';
import '../models/series_detail.dart';

class MediaRepository {
  ApiService apiService;

  List<Movie>? popularMoviesCache;

  final Map<String, SearchPageResult> searchPageCache = {};

  final Map<String, List<SearchResultItem>> personCreditsCache = {};

  Map<String, int>? _movieGenreCache;

  Map<String, int>? _tvGenreCache;

  Map<int, MovieDetail> movieDetailCache = {};

  Map<int, SeriesDetail> seriesDetailCache = {};

  Map<String, SeasonDetail> seasonDetailCache = {};

  final Map<String, List<SearchResultItem>> homeMediaCache = {};

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
    SearchPageResult result = await searchMediaPage(
      query: query,
      searchType: SearchType.title,
      page: 1,
      forceRefresh: forceRefresh,
    );

    return result.items;
  }

  Future<SearchPageResult> searchMediaPage({
    required String query,
    required SearchType searchType,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    String normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return SearchPageResult(
        items: [],
        page: 1,
        totalPages: 1,
      );
    }

    int safePage = page < 1 ? 1 : page;

    String cacheKey = '${searchType.index}_'
        '${normalizedQuery.toLowerCase()}_'
        '$safePage';

    if (!forceRefresh &&
        searchPageCache.containsKey(
          cacheKey,
        )) {
      return searchPageCache[cacheKey]!;
    }

    SearchPageResult result;

    switch (searchType) {
      case SearchType.title:
        result = await _searchByTitle(
          normalizedQuery,
          safePage,
        );
        break;

      case SearchType.actor:
        result = await _searchByPerson(
          normalizedQuery,
          safePage,
          isDirector: false,
        );
        break;

      case SearchType.director:
        result = await _searchByPerson(
          normalizedQuery,
          safePage,
          isDirector: true,
        );
        break;

      case SearchType.genre:
        result = await _searchByGenre(
          normalizedQuery,
          safePage,
        );
        break;

      case SearchType.year:
        result = await _searchByYear(
          normalizedQuery,
          safePage,
        );
        break;
    }

    searchPageCache[cacheKey] = result;

    return result;
  }

  Future<SearchPageResult> _searchByTitle(
    String query,
    int page,
  ) async {
    Map<String, dynamic> response = await apiService.get(
      '/search/multi',
      queryParameters: {
        'query': query,
        'page': page.toString(),
        'include_adult': 'false',
      },
    );

    return _parseApiPage(
      response,
    );
  }

  Future<SearchPageResult> _searchByPerson(
    String query,
    int page, {
    required bool isDirector,
  }) async {
    String personCacheKey = '${isDirector ? 'director' : 'actor'}_'
        '${query.toLowerCase()}';

    List<SearchResultItem>? cachedCredits = personCreditsCache[personCacheKey];

    if (cachedCredits == null) {
      Map<String, dynamic> personResponse = await apiService.get(
        '/search/person',
        queryParameters: {
          'query': query,
          'page': '1',
          'include_adult': 'false',
        },
      );

      List<dynamic> people = personResponse['results'] ?? [];

      if (people.isEmpty) {
        return SearchPageResult(
          items: [],
          page: 1,
          totalPages: 1,
        );
      }

      Map<String, dynamic>? selectedPerson;

      String expectedDepartment = isDirector ? 'Directing' : 'Acting';

      for (dynamic rawPerson in people) {
        if (rawPerson is! Map<String, dynamic>) {
          continue;
        }

        if (rawPerson['known_for_department'] == expectedDepartment) {
          selectedPerson = rawPerson;

          break;
        }
      }

      selectedPerson ??= Map<String, dynamic>.from(
        people.first as Map,
      );

      int personId = selectedPerson['id'] as int;

      Map<String, dynamic> creditsResponse = await apiService.get(
        '/person/$personId/combined_credits',
      );

      List<dynamic> rawCredits = isDirector
          ? creditsResponse['crew'] ?? []
          : creditsResponse['cast'] ?? [];

      Map<String, SearchResultItem> uniqueItems = {};

      for (dynamic rawCredit in rawCredits) {
        if (rawCredit is! Map) {
          continue;
        }

        Map<String, dynamic> json = Map<String, dynamic>.from(
          rawCredit,
        );

        String mediaType = json['media_type'] ?? '';

        if (mediaType != 'movie' && mediaType != 'tv') {
          continue;
        }

        if (isDirector &&
            !_isDirectorCredit(
              json,
            )) {
          continue;
        }

        int? id = json['id'] as int?;

        if (id == null) {
          continue;
        }

        String key = '${mediaType}_$id';

        uniqueItems[key] = SearchResultItem.fromJson(
          json,
        );
      }

      cachedCredits = uniqueItems.values.toList();

      personCreditsCache[personCacheKey] = cachedCredits;
    }

    return _paginateLocalResults(
      cachedCredits,
      page,
    );
  }

  bool _isDirectorCredit(
    Map<String, dynamic> json,
  ) {
    if (json['job'] == 'Director') {
      return true;
    }

    if (json['department'] == 'Directing') {
      return true;
    }

    dynamic jobs = json['jobs'];

    if (jobs is List) {
      for (dynamic rawJob in jobs) {
        if (rawJob is Map && rawJob['job'] == 'Director') {
          return true;
        }
      }
    }

    return false;
  }

  Future<SearchPageResult> _searchByGenre(
    String query,
    int page,
  ) async {
    await _loadGenreCaches();

    String normalizedGenre = query.trim().toLowerCase();

    int? movieGenreId = _findGenreId(
      _movieGenreCache!,
      normalizedGenre,
    );

    int? tvGenreId = _findGenreId(
      _tvGenreCache!,
      normalizedGenre,
    );

    if (movieGenreId == null && tvGenreId == null) {
      throw Exception(
        'ژانر واردشده پیدا نشد. نام ژانر را به انگلیسی وارد کنید.',
      );
    }

    SearchPageResult moviePage = SearchPageResult(
      items: [],
      page: page,
      totalPages: 1,
    );

    SearchPageResult tvPage = SearchPageResult(
      items: [],
      page: page,
      totalPages: 1,
    );

    if (movieGenreId != null) {
      Map<String, dynamic> response = await apiService.get(
        '/discover/movie',
        queryParameters: {
          'with_genres': movieGenreId.toString(),
          'page': page.toString(),
          'include_adult': 'false',
          'sort_by': 'popularity.desc',
        },
      );

      moviePage = _parseApiPage(
        response,
        forcedMediaType: 'movie',
      );
    }

    if (tvGenreId != null) {
      Map<String, dynamic> response = await apiService.get(
        '/discover/tv',
        queryParameters: {
          'with_genres': tvGenreId.toString(),
          'page': page.toString(),
          'include_adult': 'false',
          'sort_by': 'popularity.desc',
        },
      );

      tvPage = _parseApiPage(
        response,
        forcedMediaType: 'tv',
      );
    }

    return _combinePages(
      moviePage,
      tvPage,
      page,
    );
  }

  Future<SearchPageResult> _searchByYear(
    String query,
    int page,
  ) async {
    int? year = int.tryParse(
      query,
    );

    if (year == null || year < 1000 || year > 9999) {
      throw Exception(
        'سال انتشار را به‌صورت چهاررقمی وارد کنید.',
      );
    }

    List<Map<String, dynamic>> responses =
        await Future.wait<Map<String, dynamic>>([
      apiService.get(
        '/discover/movie',
        queryParameters: {
          'primary_release_year': year.toString(),
          'page': page.toString(),
          'include_adult': 'false',
          'sort_by': 'popularity.desc',
        },
      ),
      apiService.get(
        '/discover/tv',
        queryParameters: {
          'first_air_date_year': year.toString(),
          'page': page.toString(),
          'include_adult': 'false',
          'sort_by': 'popularity.desc',
        },
      ),
    ]);

    SearchPageResult moviePage = _parseApiPage(
      responses[0],
      forcedMediaType: 'movie',
    );

    SearchPageResult tvPage = _parseApiPage(
      responses[1],
      forcedMediaType: 'tv',
    );

    return _combinePages(
      moviePage,
      tvPage,
      page,
    );
  }

  Future<void> _loadGenreCaches() async {
    if (_movieGenreCache != null && _tvGenreCache != null) {
      return;
    }

    List<Map<String, dynamic>> responses =
        await Future.wait<Map<String, dynamic>>([
      apiService.get(
        '/genre/movie/list',
      ),
      apiService.get(
        '/genre/tv/list',
      ),
    ]);

    _movieGenreCache = _parseGenreMap(
      responses[0],
    );

    _tvGenreCache = _parseGenreMap(
      responses[1],
    );
  }

  Map<String, int> _parseGenreMap(
    Map<String, dynamic> response,
  ) {
    List<dynamic> genres = response['genres'] ?? [];

    Map<String, int> result = {};

    for (dynamic rawGenre in genres) {
      if (rawGenre is! Map<String, dynamic>) {
        continue;
      }

      String name = (rawGenre['name'] ?? '').toString().trim().toLowerCase();

      int? id = rawGenre['id'] as int?;

      if (name.isNotEmpty && id != null) {
        result[name] = id;
      }
    }

    return result;
  }

  int? _findGenreId(
    Map<String, int> genres,
    String query,
  ) {
    if (genres.containsKey(query)) {
      return genres[query];
    }

    for (MapEntry<String, int> entry in genres.entries) {
      if (entry.key.contains(
            query,
          ) ||
          query.contains(
            entry.key,
          )) {
        return entry.value;
      }
    }

    return null;
  }

  SearchPageResult _parseApiPage(
    Map<String, dynamic> response, {
    String? forcedMediaType,
  }) {
    List<dynamic> rawResults = response['results'] ?? [];

    List<SearchResultItem> items = [];

    for (dynamic rawItem in rawResults) {
      if (rawItem is! Map) {
        continue;
      }

      Map<String, dynamic> json = Map<String, dynamic>.from(
        rawItem,
      );

      if (forcedMediaType != null) {
        json['media_type'] = forcedMediaType;
      }

      String mediaType = json['media_type'] ?? '';

      if (mediaType != 'movie' && mediaType != 'tv') {
        continue;
      }

      items.add(
        SearchResultItem.fromJson(
          json,
        ),
      );
    }

    int currentPage = (response['page'] as num?)?.toInt() ?? 1;

    int totalPages = (response['total_pages'] as num?)?.toInt() ?? 1;

    if (totalPages < 1) {
      totalPages = 1;
    }

    return SearchPageResult(
      items: items,
      page: currentPage,
      totalPages: totalPages,
    );
  }

  SearchPageResult _combinePages(
    SearchPageResult first,
    SearchPageResult second,
    int page,
  ) {
    Map<String, SearchResultItem> uniqueItems = {};

    for (SearchResultItem item in [
      ...first.items,
      ...second.items,
    ]) {
      String key = '${item.mediaType}_${item.id}';

      uniqueItems[key] = item;
    }

    int totalPages = first.totalPages > second.totalPages
        ? first.totalPages
        : second.totalPages;

    return SearchPageResult(
      items: uniqueItems.values.toList(),
      page: page,
      totalPages: totalPages,
    );
  }

  SearchPageResult _paginateLocalResults(
    List<SearchResultItem> items,
    int page,
  ) {
    const int pageSize = 20;

    int totalPages = items.isEmpty ? 1 : (items.length / pageSize).ceil();

    int start = (page - 1) * pageSize;

    if (start >= items.length) {
      return SearchPageResult(
        items: [],
        page: page,
        totalPages: totalPages,
      );
    }

    int end = start + pageSize;

    if (end > items.length) {
      end = items.length;
    }

    return SearchPageResult(
      items: items.sublist(
        start,
        end,
      ),
      page: page,
      totalPages: totalPages,
    );
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

  List<SearchResultItem> parseHomeItems(
    dynamic response,
    String mediaType,
  ) {
    if (response is! Map<String, dynamic>) {
      return [];
    }

    dynamic rawResults = response['results'];

    if (rawResults is! List) {
      return [];
    }

    List<SearchResultItem> items = [];

    for (dynamic rawItem in rawResults) {
      if (rawItem is! Map) {
        continue;
      }

      Map<String, dynamic> json = Map<String, dynamic>.from(
        rawItem,
      );

      json['media_type'] = mediaType;

      items.add(
        SearchResultItem.fromJson(
          json,
        ),
      );
    }

    return items;
  }

  Future<List<SearchResultItem>> getHomeMediaList({
    required String path,
    required String mediaType,
    required String cacheKey,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && homeMediaCache.containsKey(cacheKey)) {
      return homeMediaCache[cacheKey]!;
    }

    dynamic response = await apiService.get(path);

    List<SearchResultItem> items = parseHomeItems(
      response,
      mediaType,
    );

    homeMediaCache[cacheKey] = items;

    return items;
  }

  Future<List<SearchResultItem>> getPopularMoviesForHome({
    bool forceRefresh = false,
  }) {
    return getHomeMediaList(
      path: '/movie/popular',
      mediaType: 'movie',
      cacheKey: 'popular_movies',
      forceRefresh: forceRefresh,
    );
  }

  Future<List<SearchResultItem>> getPopularSeriesForHome({
    bool forceRefresh = false,
  }) {
    return getHomeMediaList(
      path: '/tv/popular',
      mediaType: 'tv',
      cacheKey: 'popular_series',
      forceRefresh: forceRefresh,
    );
  }

  Future<List<SearchResultItem>> getNewMoviesForHome({
    bool forceRefresh = false,
  }) {
    return getHomeMediaList(
      path: '/movie/now_playing',
      mediaType: 'movie',
      cacheKey: 'new_movies',
      forceRefresh: forceRefresh,
    );
  }

  Future<List<SearchResultItem>> getNewSeriesForHome({
    bool forceRefresh = false,
  }) {
    return getHomeMediaList(
      path: '/tv/airing_today',
      mediaType: 'tv',
      cacheKey: 'new_series',
      forceRefresh: forceRefresh,
    );
  }

  Future<List<SearchResultItem>> getTopRatedMoviesForHome({
    bool forceRefresh = false,
  }) {
    return getHomeMediaList(
      path: '/movie/top_rated',
      mediaType: 'movie',
      cacheKey: 'top_rated_movies',
      forceRefresh: forceRefresh,
    );
  }

  Future<List<SearchResultItem>> getTopRatedSeriesForHome({
    bool forceRefresh = false,
  }) {
    return getHomeMediaList(
      path: '/tv/top_rated',
      mediaType: 'tv',
      cacheKey: 'top_rated_series',
      forceRefresh: forceRefresh,
    );
  }

  Future<List<SearchResultItem>> getTrendingForHome({
    bool forceRefresh = false,
  }) async {
    const String cacheKey = 'trending_all';

    if (!forceRefresh && homeMediaCache.containsKey(cacheKey)) {
      return homeMediaCache[cacheKey]!;
    }

    dynamic response = await apiService.get(
      '/trending/all/week',
    );

    if (response is! Map<String, dynamic>) {
      return [];
    }

    dynamic rawResults = response['results'];

    if (rawResults is! List) {
      return [];
    }

    List<SearchResultItem> items = [];

    for (dynamic rawItem in rawResults) {
      if (rawItem is! Map) {
        continue;
      }

      Map<String, dynamic> json = Map<String, dynamic>.from(
        rawItem,
      );

      String mediaType = json['media_type'] ?? '';

      if (mediaType != 'movie' && mediaType != 'tv') {
        continue;
      }

      items.add(
        SearchResultItem.fromJson(
          json,
        ),
      );
    }

    homeMediaCache[cacheKey] = items;

    return items;
  }

  Future<List<SearchResultItem>> getRecommendationsForHome({
    required UserMediaItem? seed,
    bool forceRefresh = false,
  }) async {
    if (seed == null) {
      return getTrendingForHome(
        forceRefresh: forceRefresh,
      );
    }

    String cacheKey = 'recommendations_'
        '${seed.mediaType}_'
        '${seed.mediaId}';

    if (!forceRefresh && homeMediaCache.containsKey(cacheKey)) {
      return homeMediaCache[cacheKey]!;
    }

    try {
      String path;

      if (seed.isMovie) {
        path = '/movie/${seed.mediaId}/recommendations';
      } else {
        path = '/tv/${seed.mediaId}/recommendations';
      }

      dynamic response = await apiService.get(path);

      List<SearchResultItem> result = parseHomeItems(
        response,
        seed.mediaType,
      );

      if (result.isEmpty) {
        return getTrendingForHome(
          forceRefresh: forceRefresh,
        );
      }

      homeMediaCache[cacheKey] = result;

      return result;
    } catch (_) {
      return getTrendingForHome(
        forceRefresh: forceRefresh,
      );
    }
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

    searchPageCache.clear();
    personCreditsCache.clear();

    movieDetailCache.clear();
    seriesDetailCache.clear();
    seasonDetailCache.clear();

    homeMediaCache.clear();

    _movieGenreCache = null;
    _tvGenreCache = null;
  }
}
