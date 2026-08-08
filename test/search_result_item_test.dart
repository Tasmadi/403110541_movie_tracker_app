import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/search_result_item.dart';

void main() {
  test(
    'Movie search result parses correctly',
    () {
      SearchResultItem item = SearchResultItem.fromJson({
        'id': 157336,
        'media_type': 'movie',
        'title': 'Interstellar',
        'original_title': 'Interstellar',
        'overview': 'Test overview',
        'poster_path': '/poster.jpg',
        'release_date': '2014-11-05',
        'vote_average': 8.4,
        'vote_count': 100,
      });

      expect(
        item.title,
        'Interstellar',
      );

      expect(
        item.isMovie,
        true,
      );

      expect(
        item.isSeries,
        false,
      );

      expect(
        item.releaseYear,
        '2014',
      );
    },
  );

  test(
    'TV search result parses correctly',
    () {
      SearchResultItem item = SearchResultItem.fromJson({
        'id': 1396,
        'media_type': 'tv',
        'name': 'Breaking Bad',
        'original_name': 'Breaking Bad',
        'overview': 'Test overview',
        'poster_path': '/poster.jpg',
        'first_air_date': '2008-01-20',
        'vote_average': 8.9,
        'vote_count': 100,
      });

      expect(
        item.title,
        'Breaking Bad',
      );

      expect(
        item.isMovie,
        false,
      );

      expect(
        item.isSeries,
        true,
      );

      expect(
        item.releaseYear,
        '2008',
      );
    },
  );
}
