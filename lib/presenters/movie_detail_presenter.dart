import '../models/movie_detail.dart';
import '../repositories/media_repository.dart';

class MovieDetailPresenter {
  MediaRepository mediaRepository;

  MovieDetailPresenter({
    required this.mediaRepository,
  });

  Future<MovieDetail> loadMovieDetail(
    int movieId, {
    bool forceRefresh = false,
  }) async {
    return mediaRepository.getMovieDetail(
      movieId,
      forceRefresh: forceRefresh,
    );
  }
}
