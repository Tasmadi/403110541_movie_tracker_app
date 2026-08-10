import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/user_media_item.dart';

void main() {
  test(
    'User media item parses database row',
    () {
      UserMediaItem item = UserMediaItem.fromMap({
        'id': 1,
        'user_id': 10,
        'media_id': 157336,
        'media_type': 'movie',
        'title': 'Interstellar',
        'poster_path': '/poster.jpg',
        'release_year': '2014',
        'watch_status': WatchStatus.watched,
        'is_favorite': 1,
        'updated_at': '2026-08-10T12:00:00',
      });

      expect(
        item.isMovie,
        true,
      );

      expect(
        item.isFavorite,
        true,
      );

      expect(
        item.watchStatus,
        WatchStatus.watched,
      );

      expect(
        item.statusTitle,
        'تماشا شده',
      );
    },
  );
}
