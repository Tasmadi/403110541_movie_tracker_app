import '../models/home_data.dart';
import '../models/search_result_item.dart';
import '../models/user_media_item.dart';
import '../repositories/media_repository.dart';
import '../repositories/user_media_repository.dart';

class HomePresenter {
  MediaRepository mediaRepository;

  UserMediaRepository userMediaRepository;

  HomePresenter({
    required this.mediaRepository,
    required this.userMediaRepository,
  });

  Future<HomeData> loadHome({
    bool forceRefresh = false,
  }) async {
    UserMediaItem? seed;

    if (!userMediaRepository.isGuest()) {
      try {
        seed = await userMediaRepository.getRecommendationSeed();
      } catch (_) {
        seed = null;
      }
    }

    List<dynamic> results = await Future.wait([
      mediaRepository.getPopularMoviesForHome(
        forceRefresh: forceRefresh,
      ),
      mediaRepository.getPopularSeriesForHome(
        forceRefresh: forceRefresh,
      ),
      mediaRepository.getNewMoviesForHome(
        forceRefresh: forceRefresh,
      ),
      mediaRepository.getNewSeriesForHome(
        forceRefresh: forceRefresh,
      ),
      mediaRepository.getTopRatedMoviesForHome(
        forceRefresh: forceRefresh,
      ),
      mediaRepository.getTopRatedSeriesForHome(
        forceRefresh: forceRefresh,
      ),
      mediaRepository.getRecommendationsForHome(
        seed: seed,
        forceRefresh: forceRefresh,
      ),
    ]);

    List<SearchResultItem> popularMovies = results[0];

    List<SearchResultItem> popularSeries = results[1];

    List<SearchResultItem> newMovies = results[2];

    List<SearchResultItem> newSeries = results[3];

    List<SearchResultItem> topMovies = results[4];

    List<SearchResultItem> topSeries = results[5];

    List<SearchResultItem> recommendations = results[6];

    return HomeData(
      popularMovies: popularMovies.take(12).toList(),
      popularSeries: popularSeries.take(12).toList(),
      newReleases: mixLists(
        newMovies,
        newSeries,
        limit: 12,
      ),
      topRated: mixLists(
        topMovies,
        topSeries,
        limit: 12,
      ),
      recommendations: recommendations.take(12).toList(),
    );
  }

  List<SearchResultItem> mixLists(
    List<SearchResultItem> first,
    List<SearchResultItem> second, {
    required int limit,
  }) {
    List<SearchResultItem> result = [];

    int index = 0;

    while (result.length < limit &&
        (index < first.length || index < second.length)) {
      if (index < first.length) {
        result.add(
          first[index],
        );
      }

      if (result.length >= limit) {
        break;
      }

      if (index < second.length) {
        result.add(
          second[index],
        );
      }

      index++;
    }

    return result;
  }
}
