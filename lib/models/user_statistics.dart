import 'user_media_item.dart';

class UserStatisticsSummary {
  int watchedMovies;
  int followedSeries;
  int favorites;

  UserStatisticsSummary({
    required this.watchedMovies,
    required this.followedSeries,
    required this.favorites,
  });
}

class UserStatisticsLocalData {
  int watchedMovies;
  int watchedSeries;
  int followedSeries;
  int watchedEpisodes;
  int favorites;

  int episodeWatchMinutes;

  int ratingCount;
  double averageRating;

  List<int> watchedMovieIds;

  List<UserMediaItem> genreCandidates;

  UserStatisticsLocalData({
    required this.watchedMovies,
    required this.watchedSeries,
    required this.followedSeries,
    required this.watchedEpisodes,
    required this.favorites,
    required this.episodeWatchMinutes,
    required this.ratingCount,
    required this.averageRating,
    required this.watchedMovieIds,
    required this.genreCandidates,
  });
}

class UserStatistics {
  int watchedMovies;
  int watchedSeries;
  int followedSeries;
  int watchedEpisodes;
  int favorites;

  int approximateWatchMinutes;

  String favoriteGenre;

  int ratingCount;
  double averageRating;

  UserStatistics({
    required this.watchedMovies,
    required this.watchedSeries,
    required this.followedSeries,
    required this.watchedEpisodes,
    required this.favorites,
    required this.approximateWatchMinutes,
    required this.favoriteGenre,
    required this.ratingCount,
    required this.averageRating,
  });

  String get watchTimeText {
    if (approximateWatchMinutes <= 0) {
      return '۰ دقیقه';
    }

    if (approximateWatchMinutes < 60) {
      return '$approximateWatchMinutes دقیقه';
    }

    int hours = approximateWatchMinutes ~/ 60;

    int minutes = approximateWatchMinutes % 60;

    if (hours < 24) {
      if (minutes == 0) {
        return '$hours ساعت';
      }

      return '$hours ساعت و $minutes دقیقه';
    }

    int days = hours ~/ 24;

    int remainingHours = hours % 24;

    if (remainingHours == 0) {
      return '$days روز';
    }

    return '$days روز و $remainingHours ساعت';
  }

  String get averageRatingText {
    if (ratingCount == 0) {
      return 'ثبت نشده';
    }

    return averageRating.toStringAsFixed(1);
  }
}
