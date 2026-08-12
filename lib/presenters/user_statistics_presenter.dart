import '../models/movie_detail.dart';
import '../models/series_detail.dart';
import '../models/user_statistics.dart';
import '../repositories/media_repository.dart';
import '../repositories/user_statistics_repository.dart';

class UserStatisticsPresenter {
  UserStatisticsRepository repository;

  MediaRepository mediaRepository;

  UserStatisticsPresenter({
    required this.repository,
    required this.mediaRepository,
  });

  bool isGuest() {
    return repository.isGuest();
  }

  Future<UserStatisticsSummary> loadSummary() {
    return repository.loadSummary();
  }

  Future<UserStatistics> loadStatistics() async {
    UserStatisticsLocalData local = await repository.loadLocalData();

    Set<int> movieIds = {
      ...local.watchedMovieIds,
    };

    Set<int> seriesIds = {};

    for (var item in local.genreCandidates) {
      if (item.isMovie) {
        movieIds.add(
          item.mediaId,
        );
      } else if (item.isSeries) {
        seriesIds.add(
          item.mediaId,
        );
      }
    }

    Map<int, MovieDetail> movieDetails = {};

    Map<int, SeriesDetail> seriesDetails = {};

    await Future.wait(
      movieIds.map(
        (movieId) async {
          try {
            MovieDetail detail = await mediaRepository.getMovieDetail(
              movieId,
            );

            movieDetails[movieId] = detail;
          } catch (_) {
            // One unavailable movie should
            // not break the statistics page.
          }
        },
      ),
    );

    await Future.wait(
      seriesIds.map(
        (seriesId) async {
          try {
            SeriesDetail detail = await mediaRepository.getSeriesDetail(
              seriesId,
            );

            seriesDetails[seriesId] = detail;
          } catch (_) {
            // Ignore unavailable series.
          }
        },
      ),
    );

    int movieWatchMinutes = 0;

    for (int movieId in local.watchedMovieIds) {
      MovieDetail? movie = movieDetails[movieId];

      if (movie != null) {
        movieWatchMinutes += movie.runtime;
      }
    }

    Map<String, int> genreCounts = {};

    for (var item in local.genreCandidates) {
      List<String> genres = [];

      if (item.isMovie) {
        genres = movieDetails[item.mediaId]?.genres ?? [];
      } else if (item.isSeries) {
        genres = seriesDetails[item.mediaId]?.genres ?? [];
      }

      for (String genre in genres) {
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }
    }

    String favoriteGenre = 'ثبت نشده';

    if (genreCounts.isNotEmpty) {
      MapEntry<String, int> favorite = genreCounts.entries.reduce(
        (
          current,
          next,
        ) {
          return next.value > current.value ? next : current;
        },
      );

      favoriteGenre = favorite.key;
    }

    int totalWatchMinutes = local.episodeWatchMinutes + movieWatchMinutes;

    return UserStatistics(
      watchedMovies: local.watchedMovies,
      watchedSeries: local.watchedSeries,
      followedSeries: local.followedSeries,
      watchedEpisodes: local.watchedEpisodes,
      favorites: local.favorites,
      approximateWatchMinutes: totalWatchMinutes,
      favoriteGenre: favoriteGenre,
      ratingCount: local.ratingCount,
      averageRating: local.averageRating,
    );
  }
}
