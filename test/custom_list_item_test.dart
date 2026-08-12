import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/custom_list_item.dart';

void main() {
  test(
    'Custom list item parses correctly',
    () {
      CustomListItem item = CustomListItem.fromMap({
        'id': 1,
        'list_id': 2,
        'media_id': 157336,
        'media_type': 'movie',
        'title': 'Interstellar',
        'poster_path': '/poster.jpg',
        'release_year': '2014',
        'added_at': '2026-08-12T10:00:00',
      });

      expect(
        item.isMovie,
        true,
      );

      expect(
        item.title,
        'Interstellar',
      );

      expect(
        item.mediaTypeTitle,
        'فیلم',
      );
    },
  );
}
