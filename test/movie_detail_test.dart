import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/movie_detail.dart';

void main() {
  test(
    'Movie detail parses TMDB data and credits',
    () {
      MovieDetail movie = MovieDetail.fromJson(
        {
          'id': 157336,
          'title': 'Interstellar',
          'original_title': 'Interstellar',
          'overview': 'Test overview',
          'poster_path': '/poster.jpg',
          'backdrop_path': '/backdrop.jpg',
          'release_date': '2014-11-05',
          'runtime': 169,
          'vote_average': 8.4,
          'vote_count': 100,
          'imdb_id': 'tt0816692',
          'genres': [
            {
              'id': 12,
              'name': 'Adventure',
            },
          ],
          'production_countries': [
            {
              'iso_3166_1': 'US',
              'name': 'United States of America',
            },
          ],
        },
        {
          'crew': [
            {
              'id': 1,
              'name': 'Christopher Nolan',
              'job': 'Director',
            },
          ],
          'cast': [
            {
              'id': 2,
              'name': 'Matthew McConaughey',
              'character': 'Cooper',
              'profile_path': '/profile.jpg',
            },
          ],
        },
      );

      expect(
        movie.title,
        'Interstellar',
      );

      expect(
        movie.releaseYear,
        '2014',
      );

      expect(
        movie.runtime,
        169,
      );

      expect(
        movie.director,
        'Christopher Nolan',
      );

      expect(
        movie.imdbId,
        'tt0816692',
      );

      expect(
        movie.cast.length,
        1,
      );
    },
  );
}
