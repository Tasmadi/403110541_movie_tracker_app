import '../models/movie.dart';
import '../repositories/media_repository.dart';

class HomePresenter {
  MediaRepository mediaRepository;

  HomePresenter({
    required this.mediaRepository,
  });

  Future<List<Movie>> loadPopularMovies({
    bool forceRefresh = false,
  }) async {
    return mediaRepository.getPopularMovies(
      forceRefresh: forceRefresh,
    );
  }
}
