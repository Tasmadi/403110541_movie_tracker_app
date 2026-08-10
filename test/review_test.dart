import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/review.dart';

void main() {
  test(
    'Review model parses database data',
    () {
      Review review = Review.fromMap(
        {
          'id': 1,
          'user_id': 10,
          'media_id': 157336,
          'media_type': 'movie',
          'review_text': 'Great movie',
          'is_spoiler': 1,
          'created_at': '2026-08-10T12:00:00',
          'updated_at': '2026-08-10T12:00:00',
          'username': 'testuser',
          'profile_image_path': null,
        },
        currentUserId: 10,
      );

      expect(
        review.text,
        'Great movie',
      );

      expect(
        review.isSpoiler,
        true,
      );

      expect(
        review.isOwnReview,
        true,
      );

      expect(
        review.username,
        'testuser',
      );

      expect(
        review.displayDate,
        '2026/08/10',
      );
    },
  );
}
