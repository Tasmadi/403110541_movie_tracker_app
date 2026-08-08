import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/movie.dart';

void main() {
  test(
    'Movie model parses TMDB data correctly',
    () {
      Movie movie = Movie.fromJson({
        'id': 157336,
        'title': 'Interstellar',
        'original_title': 'Interstellar',
        'overview': 'Test overview',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'release_date': '2014-11-05',
        'vote_average': 8.4,
        'vote_count': 100,
        'genre_ids': [12, 18, 878],
      });

      expect(
        movie.id,
        157336,
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
        movie.genreIds.length,
        3,
      );
    },
  );
}
