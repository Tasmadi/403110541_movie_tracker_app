import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/imdb_info.dart';

void main() {
  test(
    'parses IMDb rating and votes',
    () {
      ImdbInfo info = ImdbInfo.fromJson({
        'imdbRating': '8.7',
        'imdbVotes': '2,123,456',
      });

      expect(
        info.rating,
        8.7,
      );

      expect(
        info.votes,
        '2,123,456',
      );

      expect(
        info.hasRating,
        true,
      );
    },
  );

  test(
    'handles unavailable IMDb rating',
    () {
      ImdbInfo info = ImdbInfo.fromJson({
        'imdbRating': 'N/A',
        'imdbVotes': 'N/A',
      });

      expect(
        info.rating,
        isNull,
      );

      expect(
        info.votes,
        '',
      );

      expect(
        info.hasRating,
        false,
      );
    },
  );
}
