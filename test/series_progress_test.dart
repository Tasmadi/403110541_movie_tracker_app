import 'package:flutter_test/flutter_test.dart';
import 'package:movie_tracker_app/models/series_progress.dart';

void main() {
  test(
    'Series progress calculates percentage',
    () {
      SeriesProgress progress = SeriesProgress(
        watchedEpisodes: 5,
        releasedEpisodes: 10,
        remainingEpisodes: 5,
        progress: 0.5,
        state: SeriesProgressState.inProgress,
      );

      expect(
        progress.percentage,
        50,
      );

      expect(
        progress.remainingEpisodes,
        5,
      );
    },
  );
}
