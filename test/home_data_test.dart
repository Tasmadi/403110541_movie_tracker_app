import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/home_data.dart';
import 'package:movie_tracker_app/models/search_result_item.dart';

void main() {
  test(
    'Home data keeps media sections',
    () {
      SearchResultItem movie = SearchResultItem.fromJson({
        'id': 157336,
        'media_type': 'movie',
        'title': 'Interstellar',
        'original_title': 'Interstellar',
        'overview': '',
        'poster_path': null,
        'release_date': '2014-11-05',
        'vote_average': 8.5,
      });

      SearchResultItem series = SearchResultItem.fromJson({
        'id': 1396,
        'media_type': 'tv',
        'name': 'Breaking Bad',
        'original_name': 'Breaking Bad',
        'overview': '',
        'poster_path': null,
        'first_air_date': '2008-01-20',
        'vote_average': 8.9,
      });

      HomeData data = HomeData(
        popularMovies: [
          movie,
        ],
        popularSeries: [
          series,
        ],
        newReleases: [
          movie,
          series,
        ],
        topRated: [
          series,
        ],
        recommendations: [
          movie,
        ],
      );

      expect(
        data.popularMovies.length,
        1,
      );

      expect(
        data.popularSeries.first.isSeries,
        true,
      );

      expect(
        data.newReleases.length,
        2,
      );
    },
  );
}
