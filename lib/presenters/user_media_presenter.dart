import '../models/user_media_item.dart';
import '../repositories/user_media_repository.dart';

class UserMediaPresenter {
  UserMediaRepository repository;

  UserMediaPresenter({
    required this.repository,
  });

  bool isGuest() {
    return repository.isGuest();
  }

  Future<UserMediaItem?> getItem({
    required int mediaId,
    required String mediaType,
  }) {
    return repository.getItem(
      mediaId: mediaId,
      mediaType: mediaType,
    );
  }

  Future<UserMediaItem?> setStatus({
    required int mediaId,
    required String mediaType,
    required String title,
    required String? posterPath,
    required String releaseYear,
    required String watchStatus,
  }) {
    return repository.setStatus(
      mediaId: mediaId,
      mediaType: mediaType,
      title: title,
      posterPath: posterPath,
      releaseYear: releaseYear,
      watchStatus: watchStatus,
    );
  }

  Future<UserMediaItem?> toggleFavorite({
    required int mediaId,
    required String mediaType,
    required String title,
    required String? posterPath,
    required String releaseYear,
  }) {
    return repository.toggleFavorite(
      mediaId: mediaId,
      mediaType: mediaType,
      title: title,
      posterPath: posterPath,
      releaseYear: releaseYear,
    );
  }

  Future<List<UserMediaItem>> getWatching() {
    return repository.getByStatus(
      WatchStatus.watching,
    );
  }

  Future<List<UserMediaItem>> getWatched() {
    return repository.getByStatus(
      WatchStatus.watched,
    );
  }

  Future<List<UserMediaItem>> getPlanned() {
    return repository.getByStatus(
      WatchStatus.planned,
    );
  }

  Future<List<UserMediaItem>> getFavorites() {
    return repository.getFavorites();
  }
}
