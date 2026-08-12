import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/user_statistics.dart';

void main() {
  test(
    'User statistics formats watch time',
    () {
      UserStatistics statistics = UserStatistics(
        watchedMovies: 3,
        watchedSeries: 1,
        followedSeries: 2,
        watchedEpisodes: 10,
        favorites: 4,
        approximateWatchMinutes: 150,
        favoriteGenre: 'Drama',
        ratingCount: 2,
        averageRating: 4.5,
      );

      expect(
        statistics.watchTimeText,
        '2 ساعت و 30 دقیقه',
      );

      expect(
        statistics.averageRatingText,
        '4.5',
      );
    },
  );

  test(
    'No ratings shows empty rating text',
    () {
      UserStatistics statistics = UserStatistics(
        watchedMovies: 0,
        watchedSeries: 0,
        followedSeries: 0,
        watchedEpisodes: 0,
        favorites: 0,
        approximateWatchMinutes: 0,
        favoriteGenre: 'ثبت نشده',
        ratingCount: 0,
        averageRating: 0,
      );

      expect(
        statistics.averageRatingText,
        'ثبت نشده',
      );
    },
  );
}
