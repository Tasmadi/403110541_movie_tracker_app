import '../models/rating_stats.dart';
import '../repositories/rating_repository.dart';

class RatingPresenter {
  RatingRepository repository;

  RatingPresenter({
    required this.repository,
  });

  bool isGuest() {
    return repository.isGuest();
  }

  Future<RatingStats> loadStats({
    required int mediaId,
    required String mediaType,
  }) {
    return repository.getStats(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }

  Future<RatingStats> setRating({
    required int mediaId,
    required String mediaType,
    required int rating,
  }) async {
    await repository.setRating(
      mediaId: mediaId,
      mediaType: mediaType,
      rating: rating,
    );

    return repository.getStats(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }
}
