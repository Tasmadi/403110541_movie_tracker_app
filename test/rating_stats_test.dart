import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/rating_stats.dart';

void main() {
  test(
    'Rating stats returns percentages correctly',
    () {
      RatingStats stats = RatingStats(
        totalRatings: 4,
        averageRating: 4.0,
        counts: {
          1: 0,
          2: 0,
          3: 1,
          4: 2,
          5: 1,
        },
        percentages: {
          1: 0,
          2: 0,
          3: 25,
          4: 50,
          5: 25,
        },
        userRating: 4,
      );

      expect(
        stats.getRoundedPercentage(
          4,
        ),
        50,
      );

      expect(
        stats.getCount(4),
        2,
      );

      expect(
        stats.averageRating,
        4,
      );
    },
  );
}
