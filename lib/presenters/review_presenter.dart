import '../models/review.dart';
import '../repositories/review_repository.dart';

class ReviewPresenter {
  ReviewRepository repository;

  ReviewPresenter({
    required this.repository,
  });

  bool isGuest() {
    return repository.isGuest();
  }

  Future<List<Review>> loadReviews({
    required int mediaId,
    required String mediaType,
  }) {
    return repository.getReviews(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }

  Future<List<Review>> saveReview({
    required int mediaId,
    required String mediaType,
    required String text,
    required bool isSpoiler,
  }) async {
    await repository.saveReview(
      mediaId: mediaId,
      mediaType: mediaType,
      text: text,
      isSpoiler: isSpoiler,
    );

    return repository.getReviews(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }
}
